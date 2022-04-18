from mo_sql_parsing import parse, format
import traceback
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from loader import Loader
from config import FileType, get_filename
import constraint 
from extract_rule import ExtractQueryRule
from utils import GlobalExpRecorder

# ------------------------------------------------------------------------------
# This script counts queries has table column with a certain type of constraints
# dump the results into logs. Here's how to run this script: 
# run under autrite directory: python3 benchmark/extract_query.py
# option to verbal for debug purpose: python3 benchmark/extract_query.py -v
# ------------------------------------------------------------------------------
def main(verbal) -> None:
    # make sure log file is clean
    recorder = GlobalExpRecorder()
    recorder.clear(get_filename(FileType.PRECHECK_STR2INT_NUM, None))

    appnames = ['forem', 'redmine', 'openproject']
    name_to_type = {'inclusion': constraint.InclusionConstraint, 
               'length': constraint.LengthConstraint, 
               'format': constraint.FormatConstraint}

    for appname in appnames:
        # load query once for each app
        queries = load_queries(appname)
        recorder.record("app_name", appname)
        # count the number of queries with constraints on it 
        all_cs = load_cs(appname, 'all')
        all_cnt = count(all_cs, queries, verbal)
        recorder.record("queries_with_cs", all_cnt)
        for type_name in name_to_type.keys():
            cs_type = name_to_type[type_name]
            filtered_cs = load_cs(appname, cs_type)
            cnt = count(filtered_cs, queries, verbal)
            recorder.record(type_name, cnt)
        recorder.dump(get_filename(FileType.PRECHECK_STR2INT_NUM, None))
        
#################################
#        helper functions       #
#################################
# load queries
def load_queries(appname) -> list:
    app_to_cnt = {"redmine": 262462, "forem": 183483, "openproject": 22021}
    # app_to_cnt = {"redmine": 100, "forem": 100, "openproject": 100}
    query_filename = get_filename(FileType.RAW_QUERY, appname)
    offset = 0
    query_cnt = app_to_cnt[appname]
    queries = Loader.load_queries(query_filename, offset, query_cnt)
    return queries

# return filtered constraints
def load_cs(appname, cs_type) -> list:
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    constraints = Loader.load_constraints(constraint_filename)
    if cs_type == 'all':
        return constraints
    filtered_cs = [c for c in constraints if isinstance(c, cs_type)]
    return filtered_cs

# return number of queries contains filtered constraints
def count(filtered_cs, queries, verbal) -> int:
    cnt = 0
    for q in queries:
        try:
            rewrite_q = ExtractQueryRule(filtered_cs).apply(q.q_obj)
            if extracted(rewrite_q):
                cnt += 1
        except (KeyError, TypeError, AttributeError, ValueError):
            print_error(q, verbal)
    return cnt

# return True if query contains inclusion constrains
def extracted(q) -> bool:
    # rewrite_q is a list of queries from the rewrite rules
    return len(q) == 1

# print info about errored query
def print_error(q, verbal) -> None:
    if verbal:
        print(q.q_raw)
        print("----------------")
        print(traceback.format_exc())
        print("================")
    else:
        pass

if __name__=="__main__":
    verbal = len(sys.argv) > 1
    main(verbal)