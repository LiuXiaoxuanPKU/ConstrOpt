import os, sys
import traceback
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils import exp_recorder
from tqdm import tqdm
from mo_sql_parsing import parse
from config import get_filename, FileType, CONNECT_MAP, RewriteQuery
from utils import load_json_queries
from evaluator import Evaluator
from loader import Loader
from rewriter import Rewriter
from TestVerifier import TestVerifier
import rule

# get average number of rewrites
def get_avg_rewrite_num(appname):
    print("=========Get average number of rewrites for %s =========" % appname)
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    constraints = Loader.load_constraints(constraint_filename)
    rewrite_filename = get_filename(FileType.REWRITE, appname)
    queries = load_json_queries(rewrite_filename)
    
    rules = [rule.RemovePredicate, rule.RemoveDistinct, rule.RewriteNullPredicate,
             rule.AddLimitOne, rule.RemoveJoin, rule.AddPredicate, rule.ReplaceOuterJoin] 
    rewriter = Rewriter()
    rewriter.set_rules(rules)
    
    rewrites_cnt = []
    rewrites_pass_test_cnt = []
    for q in tqdm(queries):
        try:
            q = RewriteQuery(parse(q['org_q']))
            rewritten_queries = rewriter.rewrite(constraints, q)
        except:
            print("[Error rewrite]", format(q.q))
            print(traceback.format_exc())
            continue
        if len(rewritten_queries) == 0:
            continue
        # use tests to check equivalence
        param_verified_queries = TestVerifier().verify(appname, q, constraints, rewritten_queries)
        rewrites_cnt.append(len(rewritten_queries))
        rewrites_pass_test_cnt.append(len(param_verified_queries))
    print("Avg # of rewrites: %f\tAvg $ of rewrites pass tests: %f" % \
        (sum(rewrites_cnt)/len(rewrites_cnt), sum(rewrites_pass_test_cnt)/len(rewrites_pass_test_cnt)))

# get number of rewrites with empty results
def get_empty_result_rewrite(appname):
    print("=========Get empty results ratio for %s =========" % appname)
    rewrite_filename = get_filename(FileType.REWRITE, appname)
    rewrite_objs = load_json_queries(rewrite_filename)
    results_cnt = {}
    for rq in rewrite_objs:
        results = Evaluator.evaluate_query(rq['org_q'], CONNECT_MAP[appname])
        if len(results) not in results_cnt:
            results_cnt[len(results)] = 0
        results_cnt[len(results)] += 1
        
        if len(results) == 0:
            exp_recorder.record("rules", rq['rules'])
            exp_recorder.record("org_q", rq['org_q'])
            exp_recorder.record("rewrite_q", rq['rewrite_q'])
            exp_recorder.dump(get_filename(FileType.EMPTY_RESULT_QUERY, appname))
    
    for i in range(0, 5):
        if i in results_cnt: 
            print("App: %s\t# of results: %d\tcount/total: %d/%d" % (appname, i, results_cnt[i], len(rewrite_objs)))

if __name__ == "__main__":
    appname = 'redmine'
    # get_avg_rewrite_num(appname)
    get_empty_result_rewrite(appname)
