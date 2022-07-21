import os.path, json, traceback

from loader import Loader
from evaluator import Evaluator
import numpy as np
from utils import exp_recorder, generate_query_param_single,\
    generate_query_params, get_str_hash, test_query_result_equivalence,\
    load_json_queries
from config import CONNECT_MAP, FileType, get_filename
import constraint
from mo_sql_parsing import format
from tqdm import tqdm

import matplotlib.pyplot as plt

class EvalQuery:
    def __init__(self, template) -> None:
        self.template = template
        self.before = None
        self.after = None
        self.rewrites = []
        
        self.raw_cost = -1
        self.raw_t = -1
        self.raw_plan = None
        
        self.constraint_cost = -1
        self.constraint_t = -1
        self.constraint_plan = None
        
        self.rewrite_cost = -1
        self.rewrite_t = -1
        self.rewrite_plan = None
        
        self.constraint_rewrite_cost = -1
        self.constraint_rewrite_t = -1
        self.constraint_rewrite_plan = None

    
def clean_constraints(constraints):
    print("===========Clean constraints==============")
    for c in tqdm(constraints):
        if c.table is None:
            continue
        if type(c) in [constraint.UniqueConstraint, constraint.NumericalConstraint]:
            constraint_name = str(c)
            drop_sql = "ALTER TABLE %s DROP CONSTRAINT IF EXISTS %s;" %(c.table, constraint_name)
            Evaluator.evaluate_query(drop_sql, CONNECT_MAP[appname])
        elif type(c) in [constraint.PresenceConstraint]:
            constraint_name = str(c)
            drop_sql = "ALTER TABLE %s ALTER COLUMN %s DROP NOT NULL;" %(c.table, c.field)
            try:
                Evaluator.evaluate_query(drop_sql, CONNECT_MAP[appname])
            except: # column might not exist
                pass
                    
def install_constraints(constraints):
    installed_constraints = []
    print("=============Install constraints============")
    for c in tqdm(constraints):
        if c.table is None:
            continue
        elif isinstance(c, constraint.UniqueConstraint):
            constraint_name = str(c)
            roll_back_info = (c, constraint_name)
            fields = [c.field] + c.scope
            fields = ', '.join(fields)
            install_sql = "ALTER TABLE %s ADD CONSTRAINT %s UNIQUE (%s);" % (c.table, constraint_name, fields)
        elif isinstance(c, constraint.PresenceConstraint):
            constraint_name = str(c)
            roll_back_info = (c, constraint_name)
            install_sql = "ALTER TABLE %s ALTER COLUMN %s SET NOT NULL;" % (c.table, c.field)
        elif isinstance(c, constraint.NumericalConstraint):
            constraint_name = str(c)
            roll_back_info = (c, constraint_name)
            if c.min is not None and c.max is None:
                install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} > {});".format(
                    c.table, constraint_name, c.field, c.min)
            elif c.min is None and c.max is not None:
                install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} < {});".format(
                    c.table, constraint_name, c.field, c.max)
            else:
                install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} > {} AND {} < {});".format(
                    c.table, constraint_name, c.field, c.min, c.field, c.max)
        
        try:
            Evaluator.evaluate_query(install_sql, CONNECT_MAP[appname])
            installed_constraints.append(roll_back_info)
        except Exception as e:
            print(traceback.format_exc())
    print("Install constraints success/all: %d/%d" % (len(installed_constraints), len(constraints)))
    return installed_constraints            

# does not catch exception here, roll back shoud succeed
def roll_back(installed_constraints):
    for roll_back_info in installed_constraints:
        c, constraint_name = roll_back_info
        if type(c) in [constraint.NumericalConstraint, constraint.UniqueConstraint]:
            drop_sql = "ALTER TABLE %s DROP CONSTRAINT IF EXISTS %s;" % (c.table, constraint_name)
        elif type(c) in [constraint.PresenceConstraint]:
            drop_sql = "ALTER TABLE %s ALTER COLUMN %s DROP NOT NULL;" %(c.table, c.field)
        Evaluator.evaluate_query(drop_sql, CONNECT_MAP[appname])

def filter_queries(queries, constraints):
    q_with_constraints = []
    def extract_q_field(q):
        # TODO: extract all the fields insteaf of all the tokens
        tokens = [t.lower().split('.')[-1] for t in q.split(' ')]
        return tokens

    def get_field_constraint(field, constraints):
        field_constraints = []
        for c in constraints:
            if c.field == field:
                field_constraints.append(c)
        return field_constraints

    for q in queries:
        # extract fields in q
        fields = extract_q_field(q)
        has_c = False
        for field in fields:
            cs = get_field_constraint(field, constraints)
            if len(cs) > 0:
                has_c = True
                break
        if has_c:
            q_with_constraints.append(q)
            
    return q_with_constraints
        

# get all the queries, incluing queries that cannot be rewritten
# for each raw query, there will be an entry, and use rewrites to fill out raw queries
# we also generate parameters for raw queries in the step
# the step prepare the inputs for evaluation
def get_all_queries(appname):
    rewrite_filename = get_filename(FileType.REWRITE, appname)
    rewrite_objs = load_json_queries(rewrite_filename)
    rewrite_map = {}
    for obj in rewrite_objs:
        rewrite_map[obj['id']]= obj
    
    query_file =  get_filename(FileType.RAW_QUERY, appname)
    queries = Loader.load_queries(query_file, offset=0, cnt=10000)
    queries = [EvalQuery(format(q)) for q in queries]
    for q in queries:
        key = get_str_hash(q.template)
        if key in rewrite_map:
            q.before = rewrite_map[key]['org_q']
            q.after = rewrite_map[key]['rewrite_q']
            q.rewrites += rewrite_map[key]['rules']
        else:
            param_q = generate_query_param_single([q.template], CONNECT_MAP[appname], {})
            if param_q is not None:
                q.before = param_q
                q.after = param_q
            else:
                q.before = None
                q.after = None
    
    for q in queries:
        if q.before and q.after:
            exp_recorder.record("template", q.template)
            exp_recorder.record("before", q.before)
            exp_recorder.record("after", q.after)
            exp_recorder.record("rewrites", q.rewrites)
            exp_recorder.dump(get_filename(FileType.PARAM_QUERY, appname))

# Get query performance
# pg performance with db constraints
# constropt performance with db constraints --> missing
# pg performance with db + model constraints
# constropt performance with db + model constraints  
def get_all_perf(appname):
    all_filename = get_filename(FileType.PARAM_QUERY, appname)
    q_objs = load_json_queries(all_filename)
    queries = []
    for obj in q_objs:
        q = EvalQuery(obj['template'])
        q.before, q.after = obj['before'], obj['after']
        q.rewrites = obj["rewrites"]
        queries.append(q)

    constraint_file = get_filename(FileType.CONSTRAINT, appname)
    constraints = Loader.load_constraints(constraint_file)
    clean_constraints(constraints)
    
    print("=========Org===============")
    # no constraints, no rewrites
    for q in tqdm(queries):
        try:
            q.raw_cost = Evaluator.evaluate_cost(q.before, CONNECT_MAP[appname])
            q.raw_t = Evaluator.evaluate_actual_time(q.before, CONNECT_MAP[appname])
            q.raw_plan = Evaluator.evaluate_query("EXPLAIN " + q.before, CONNECT_MAP[appname])
        except:
            q.raw_cost = None
            q.raw_t = None
            q.raw_plan = None
        
    print("=========DB===============")
    # with constraints
    roll_back_info = install_constraints(constraints)
    for q in tqdm(queries):
        try:
            q.constraint_cost = Evaluator.evaluate_cost(q.before, CONNECT_MAP[appname])
            q.constraint_t = Evaluator.evaluate_actual_time(q.before, CONNECT_MAP[appname])
            q.constraint_plan = Evaluator.evaluate_query("EXPLAIN " + q.before, CONNECT_MAP[appname])
        except:
            q.constraint_cost = None
            q.constraint_t = None
            q.constraint_plan = None
    
    print("=========DB + Rewrite===============")
    # with constraints + rewrites
    for q in tqdm(queries):
        try:
            q.constraint_rewrite_cost = Evaluator.evaluate_cost(q.after, CONNECT_MAP[appname])
            q.constraint_rewrite_t = Evaluator.evaluate_actual_time(q.after, CONNECT_MAP[appname])
            q.constraint_rewrite_plan = Evaluator.evaluate_query("EXPLAIN " + q.after, CONNECT_MAP[appname])
        except:
            q.constraint_rewrite_cost = None
            q.constraint_rewrite_t = None
            q.constraint_rewrite_plan = None
    
    roll_back(roll_back_info)
    for q in queries:
        # exp_recorder.record("template", q.template)
        exp_recorder.record("org_cost", q.raw_cost)
        exp_recorder.record("org_t", q.raw_t)
        exp_recorder.record("db_cost", q.constraint_cost)
        exp_recorder.record("db_t", q.constraint_t)
        exp_recorder.record("db_rewrite_cost", q.constraint_rewrite_cost)
        exp_recorder.record("db_rewrite_t", q.constraint_rewrite_t)
        
        exp_recorder.record("before", q.before)
        exp_recorder.record("after", q.after)
        exp_recorder.record("rewrites", q.rewrites)
        exp_recorder.record("org_plan", q.raw_plan)
        exp_recorder.record("db_plan", q.constraint_plan)
        exp_recorder.record("db_rewrite_plan", q.constraint_rewrite_plan)
          
        exp_recorder.dump(get_filename(FileType.REWRITE_DB_PERF, appname))


def get_slow_queries(appname, queries, ratio):
    ts = []
    for q in queries:
        if len(q) < 5:
            ts.append(-1)
            continue
        try:
            ts.append(Evaluator.evaluate_actual_time(q, connect_string=CONNECT_MAP[appname]))
        except:
            print("[Fail to execute]", q)
            ts.append(-1)
    ts_array = np.array(ts)
    percentile_t = np.percentile(ts_array[ts_array>0], (1 - ratio)*100)
    slow_queries = []
    slow_ts = []
    for i, t in enumerate(ts):
        if t > percentile_t:
            slow_queries.append(queries[i])
            slow_ts.append(t)
    return slow_queries, slow_ts

def count_rewrite(appname):
    filename = get_filename(FileType.REWRITE_DB_PERF, appname)
    objs = load_json_queries(filename)
    db_cnt = 0
    db_rewrite_cnt = 0
    db_speedup = 0
    db_rewrite_speedup = 0
    db_rewrite_speedup_by_groups = {}
    for obj in objs:
        if obj['org_plan'] is None or obj['db_plan'] is None:
            continue
        db_eq = test_query_result_equivalence(obj['org_plan'], obj['db_plan'])
        if not db_eq:
            db_cnt += 1     
        db_rewrite_eq = test_query_result_equivalence(obj['org_plan'], obj['db_rewrite_plan'])
        if not db_rewrite_eq:
            db_rewrite_cnt += 1
            # db_speedup += (obj['org_cost'] * 1.0 / obj['db_cost'])
            db_speedup += (obj['org_t'] * 1.0 / obj['db_t'])
            # db_rewrite_speedup += (obj['org_cost'] * 1.0 / obj['db_rewrite_cost'])
            db_rewrite_speedup += (obj['org_t'] * 1.0 / obj['db_rewrite_t'])
            for rt in obj['rewrites']:
                if rt not in db_rewrite_speedup_by_groups:
                    db_rewrite_speedup_by_groups[rt] = []
                db_rewrite_speedup_by_groups[rt].append(obj['org_t'] * 1.0 / obj['db_rewrite_t'])
               
    for rt in db_rewrite_speedup_by_groups.keys():
        fig, ax = plt.subplots()
        
        ax.hist(db_rewrite_speedup_by_groups[rt])
        plt.savefig(rt)
        plt.close()
         
    print("DB count %d" % db_cnt)
    print("DB Rewrite count %d" % db_rewrite_cnt)
    print("DB speed up %f" % (db_speedup / db_rewrite_cnt))
    print("DB Rewrite speed up %f" % (db_rewrite_speedup / db_rewrite_cnt))
    

def benchmark_rewrite(appname):
    filename = get_filename(FileType.REWRITE_DB_PERF, appname)
    objs = load_json_queries(filename)
    

if __name__ == "__main__":
    appname = "redmine"
    bench_slow_queries = False
    bench_all = False
    get_rewrite_cnt = True
    get_rewrite_perf = False
    
    
    param_q_file = get_filename(FileType.PARAM_QUERY, appname)
    if not os.path.isfile(param_q_file):
        get_all_queries(appname)
    
    if bench_all:
        get_all_perf(appname)
        
    if bench_slow_queries:
        filename = get_filename(FileType.RAW_QUERY, appname)
        queries = Loader.load_queries_raw(filename, cnt=1000)
        queries = generate_query_params(queries, CONNECT_MAP[appname])
        slow_queries, slow_ts = get_slow_queries(queries, 0.1)
        
        for q,t in zip(slow_queries, slow_ts):
            exp_recorder.record("time(ms)", t)
            exp_recorder.record("queries", q)
            exp_recorder.dump("logs/slow_queries")
    
    
    if get_rewrite_cnt:
        count_rewrite(appname)
        
    if get_rewrite_perf:
        benchmark_rewrite(appname)
    
