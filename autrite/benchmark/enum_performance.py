from statistics import mean
import psycopg2
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from evaluator import Evaluator
from config import FileType, get_filename
from loader import Loader
from config import CONNECT_MAP
from constraint import InclusionConstraint
from utils import GlobalExpRecorder, generate_query_params, generate_query_param_single, generate_query_param_rewrites

# 1. run all the queries has inclusion constraints with original table
#     input: a list of sqls with inclusion constraints in it 
#     output: average timing for each query

# 2. copy phisical table
#     input: list of pairs of table-column in inclusion constraints
     
# 3. create enum type, convert inclusion constraint columns to enum type
#    input: inclusion constraints
#    output: a list of sqls to execute

# 4. generate new queries. e.g. change table_name to table_name_new

# 5. run new queries in new table (each table run 5 times get the ave time, only record ave time)
# format: sql: ...; before: ...; after: ...; dump to log 
# =================================================================


# ===================== static variables ==========================
appname = "redmine"
offset = 0
app_to_cnt = {"redmine": 262462, "forem": 183483, "openproject": 22021}
query_cnt = 500
run_times = 5
# ===================== helper functions ==========================
# alter column from enum to VarChar. 
# Input: a list of constraints; Output: a list of sqls
def enum_to_varchar(cs) -> list:
    sqls = []
    for c in cs:
        sql = "alter table {} alter column {} type varchar;".format(c.table, c.field)
        sqls.append(sql)
    return sqls

# create a copy of table schemas
def create_table(cs) -> list:
    tables = set([c.table for c in cs])
    sqls = []
    for t in tables:
        new_t = "{}_test_str2int".format(t)
        # DROP if existed in case they duplicate
        Evaluator.evaluate_query("DROP TABLE IF EXISTS {}".format(new_t), CONNECT_MAP[appname])
        sql = "CREATE TABLE {} ( like {} INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING INDEXES );".format(new_t, t)
        sqls.append(sql)
    return sqls

# insert values to the copied table
def insert_value(cs) -> list:  
    tables = set([c.table for c in cs])
    sqls = []
    for t in tables:
        new_t = "{}_test_str2int".format(t)
        # truncate data first 
        Evaluator.evaluate_query("truncate {};".format(new_t), CONNECT_MAP[appname])
        sql = "insert into {} select * from {};".format(new_t, t)
        sqls.append(sql)
    return sqls
    
# generate a list of sqls to create new enum type
def generate_enum_type(cs) -> list:
    
    # create TYPE table_column_value as ENUM ('value1', 'value2', 'value3', 'value4');
    def get_enum_value(c) -> list:
        sql = "select distinct({}) from {}".format(c.field, c.table)
        raw_values = Evaluator.evaluate_query(sql, CONNECT_MAP[appname])
        return raw_values

    # return a str list of possible values
    def parse_enum_value(raw_values) -> str:
        # raw_values format: [('AnonymousUser',), ('User',), ('GroupNonMember',), ('GroupAnonymous',), ('Group',)]
        values = [v[0] for v in raw_values if v[0] is not None]
        return "({})".format(str(values)[1:-1])
    
    sqls = []
    for c in cs:
        table = c.table
        field = c.field
        raw_values = get_enum_value(c)
        values = parse_enum_value(raw_values)
        # sql = "create TYPE {}_{}_values as ENUM {};".format(table, field, values)
        sql = "DO $$ BEGIN CREATE TYPE {}_{}_values AS ENUM {}; EXCEPTION WHEN duplicate_object THEN null; END $$;".format(table, field, values)
        sqls.append(sql)
    return sqls

# alter field type of the copied table to enum type
def alter_type(cs) -> list:
    # ALTER TABLE t_test_str2int ALTER COLUMN c TYPE table_column_value USING c::table_column_value;
    sqls = []
    for c in cs:
        new_t = "{}_test_str2int".format(c.table)
        field = c.field
        type_name = "{}_{}_values".format(c.table, c.field)
        sql = "ALTER TABLE {} ALTER COLUMN {} TYPE {} USING {}::{};".format(
            new_t, field, type_name, field, type_name)
        sqls.append(sql)
    return sqls

# generate a list of new sqls to evaluate performance [write a new apply to single?]
def generate_new_sqls(sqls, cs) -> list:

    # get inclusion tables as a set
    def get_tables(cs) -> set:
        return set([c.table for c in cs])

    def apply_single(sql, tables):
        for t in tables:
            if t in sql:
                new_t = "{}_test_str2int".format(t)
                sql = sql.replace(t, new_t)
        return sql

    tables = get_tables(cs)
    new_sqls = []
    for sql in sqls:
        new_sql = apply_single(sql, tables)
        new_sqls.append(new_sql)
    return new_sqls

# running a list of sql commands
def run_sqls(sqls) -> None:
    for sql in sqls:
        try:
            message = Evaluator.evaluate_query(sql, CONNECT_MAP[appname])
            if len(message) != 0: 
                print(message)
        except psycopg2.errors.DatatypeMismatch as e:
            print(e)
     
# check the time, and dump into the log file    
def timing(sqls, times=run_times):
    def timing_single(sql) -> float:
        timings = [Evaluator.evaluate_actual_time(sql, CONNECT_MAP[appname]) for _ in range(times)]
        return mean(timings)
    timings = []
    for sql in sqls:
        try:
            ave_timing = timing_single(sql)
            timings.append(ave_timing)
        except (TypeError, psycopg2.errors.UndefinedFunction) as e:
            print(sql)
            print(e)
    return timings
        
# load inclusion constraints as a list
def load_inclusion_cs() -> list:
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    constraints = Loader.load_constraints(constraint_filename)
    inclusion_constraints = [c for c in constraints if isinstance(c, InclusionConstraint)]
    return inclusion_constraints

def record(sqls, before, after) -> None:
    # make sure the log file is clean first
    recorder = GlobalExpRecorder()
    recorder.clear(get_filename(FileType.ENUM_EVAL, appname))

    assert(len(sqls) == len(before) and len(sqls) == len(after))
    for obj in zip(sqls, before, after):
        recorder.record("sql", obj[0])
        recorder.record("before", obj[1])
        recorder.record("after", obj[2])
        recorder.dump(get_filename(FileType.ENUM_EVAL, appname))
        
# return a list od sqls with proper params
def add_params(sqls) -> list:
    ret = []
    for sql in sqls:
        add_p = generate_query_param_single(sql, CONNECT_MAP[appname], {})
        if add_p is not None:
            ret.append(add_p)
        else:
            ret.append(sql)
    return ret
    
# ============================= main ================================
if __name__ == "__main__":
    query_filename = get_filename(FileType.RAW_QUERY, appname)
    queries = Loader.load_queries(query_filename, offset, query_cnt)
    sqls = [q.q_raw for q in queries]
    sqls = add_params(sqls)
    inclusion_cs = load_inclusion_cs()
    
    # 0. make sure original tables has varchar as field type
    run_sqls(enum_to_varchar(inclusion_cs))
    
    # 1 run original queries, calculate time
    before_timings = timing(sqls)
    
    # 2 copy physical table
    run_sqls(create_table(inclusion_cs))
    
    # 3.a insert values
    run_sqls(insert_value(inclusion_cs))
    
    # 3.b create enum type
    run_sqls(generate_enum_type(inclusion_cs))
    
    # 4 alter enum type in duplicated new table
    run_sqls(alter_type(inclusion_cs))
    
    # 5.a generate new sqls
    new_sqls = generate_new_sqls(sqls, inclusion_cs)
    
    # 5.b run new queries, calculate time 
    after_timings = timing(new_sqls)

    # 6 record sql, before & after timing, and dump to file
    record(sqls, before_timings, after_timings)
    
    
    