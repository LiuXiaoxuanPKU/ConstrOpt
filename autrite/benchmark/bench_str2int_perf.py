from curses import raw
from inspect import trace
from statistics import mean
from pandas import qcut
import psycopg2
import sys, os
import traceback
from enum import Enum
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from evaluator import Evaluator
from config import FileType, get_filename
from loader import Loader
from config import CONNECT_MAP
from constraint import InclusionConstraint
from utils import GlobalExpRecorder, generate_query_param_single
from tqdm import tqdm
from extract_rule import ExtractQueryRule
from bench_utils import get_valid_queries
import argparse

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

class EvalQuery:
    def __init__(self, raw_sql) -> None:
        self.raw = raw_sql
        self.before_sql = None
        self.after_sql = None
        self.before_time = None
        self.after_time = None

class Stage(Enum):
    BEFORE = 1
    AFTER = 2

# ===================== static variables ==========================
parser = argparse.ArgumentParser()
parser.add_argument('--app', default='openproject')
parser.add_argument('--cnt', default='100')

args = parser.parse_args()
appname = args.app
query_cnt = int(args.cnt)
if query_cnt == -1:
    app_to_cnt = {"redmine": 262462, "forem": 183483, "openproject": 22021}
    query_cnt = 182483

offset = 0
run_times = 1
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
   
def add_quo(field):
    if field in ["group"]:
        return '"' + field + '"'
    return field

# generate a list of sqls to create new enum type
def generate_enum_type(cs) -> list:
    
    # create TYPE table_column_value as ENUM ('value1', 'value2', 'value3', 'value4');
    def get_enum_value(c) -> list:
        sql = "select distinct({}) from {}".format(add_quo(c.field), c.table)
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
        sql = "DROP TYPE IF EXISTS {}_{}_values".format(table, field)
        sqls.append(sql)
        sql = "CREATE TYPE {}_{}_values AS ENUM {}".format(table, field, values)
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
        sql = "alter table {} alter \"{}\" drop default".format(new_t, field)
        sqls.append(sql)
        sql = "ALTER TABLE {} ALTER COLUMN {} TYPE {} USING {}::{};".format(
            new_t, field, type_name, field, type_name)
        sqls.append(sql)
    return sqls

# generate a list of new sqls to evaluate performance [write a new apply to single?]
def generate_new_sqls(qs, cs) -> list:

    # get inclusion tables as a set
    def get_tables(cs) -> set:
        return set([c.table for c in cs])

    def apply_single(sql, tables):
        for t in tables:
            if t in sql:
                new_t = "{}_test_str2int".format(t)
                if sql.endswith(t):
                   sql = sql.replace(" " + t, " " + new_t) 
                
                sql = sql.replace("(" + t + ".", "(" + new_t + ".")
                sql = sql.replace(" " + t + ".", " " + new_t + ".")
                sql = sql.replace(" " + t + " ", " " + new_t + " ")
                
        return sql

    tables = get_tables(cs)
    new_sqls = []
    for q in qs:
        q.after_sql = apply_single(q.before_sql, tables)
        new_sqls.append(q)
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
        except:
            print(traceback.format_exc())
     
# check the time, and dump into the log file    
def timing(qs, stage, times=run_times):
    timing_qs = []
    for q in qs:
        try:
            if stage == Stage.BEFORE:
                # timings = [Evaluator.evaluate_actual_time(q.before_sql, CONNECT_MAP[appname]) for _ in range(times)]
                timings = [Evaluator.evaluate_cost(q.before_sql, CONNECT_MAP[appname]) for _ in range(times)]
                q.before_time = mean(timings)
            elif stage == Stage.AFTER:
                # timings = [Evaluator.evaluate_actual_time(q.after_sql, CONNECT_MAP[appname]) for _ in range(times)]
                timings = [Evaluator.evaluate_cost(q.after_sql, CONNECT_MAP[appname]) for _ in range(times)]
                q.after_time = mean(timings)
            timing_qs.append(q)
        except (TypeError, psycopg2.errors.UndefinedFunction) as e:
            print(q.raw)
            print(e)
        except:
            print("[Error] Fail to eval ", q.before_sql)
            print(traceback.format_exc())
    return timing_qs
        
# load inclusion constraints as a list
def load_inclusion_cs() -> list:
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    constraints = Loader.load_constraints(constraint_filename)
    inclusion_constraints = [c for c in constraints if isinstance(c, InclusionConstraint)]
    return inclusion_constraints

def record(qs) -> None:
    # make sure the log file is clean first
    recorder = GlobalExpRecorder()
    recorder.clear(get_filename(FileType.ENUM_EVAL, appname))

    for q in qs:
        recorder.record("before_time", q.before_time)
        recorder.record("after_time", q.after_time)
        recorder.record("template", q.raw)
        recorder.record("before", q.before_sql)
        recorder.record("after", q.after_sql)
        recorder.dump(get_filename(FileType.ENUM_EVAL, appname))
        
# return a list od sqls with proper params
def add_params(qs) -> list:
    ret = []
    for q in qs:
        add_p = generate_query_param_single(q.raw, CONNECT_MAP[appname], {})
        if add_p is None:
            continue
        q.before_sql = add_p
        ret.append(q)
    return ret
    
# ============================= main ================================
if __name__ == "__main__":
    query_filename = get_filename(FileType.RAW_QUERY, appname)
    queries = Loader.load_queries(query_filename, offset, query_cnt)
    queries = get_valid_queries(queries, CONNECT_MAP[appname])
    inclusion_cs = load_inclusion_cs()
    rule = ExtractQueryRule(inclusion_cs)

    print("========= Extract Str2Int Queries=========")
    rewrite_qs = []
    for q in queries:
        if len(rule.apply(q.q_obj)) > 0:
            rewrite_qs.append(q)
    print("Number of rewrite queries: %d" % len(rewrite_qs))
    qs = [EvalQuery(q.q_raw) for q in rewrite_qs]
    print("========Add SQL param==================")
    qs = add_params(qs)
    print("Number of optmized queries: %d" % len(qs))
    
    ## 0. make sure original tables has varchar as field type
    # print("========Change datatype to varchar==========")
    # run_sqls(enum_to_varchar(inclusion_cs))
    
    # 1 run original queries, calculate time
    print("========Eval time before changing storage==========")
    qs = timing(qs, Stage.BEFORE)
    print("Number of evaluated queries: %d" % len(qs))
    
    # # 2 copy physical table
    # print("========Create table===========")
    # run_sqls(create_table(inclusion_cs))
    
    # # 3.a insert values
    # print("========Insert value to new table===========")
    # run_sqls(insert_value(inclusion_cs))
    
    # # 3.b create enum type
    # print("========Create Enum type===========")
    # run_sqls(generate_enum_type(inclusion_cs))
    
    # # 4 alter enum type in duplicated new table
    # print("========Change Enum type===========")
    # run_sqls(alter_type(inclusion_cs))
    
    # 5.a generate new sqls
    print("========Generate new sql===========")
    qs = generate_new_sqls(qs, inclusion_cs)
    
    # 5.b run new queries, calculate time 
    print("========Eval new sqls===========")
    qs = timing(qs, Stage.AFTER)
 
    # 6 record sql, before & after timing, and dump to file
    print("========Dump result===========", len(qs))
    record(qs)
    
    
    