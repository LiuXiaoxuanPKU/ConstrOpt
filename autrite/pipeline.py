import traceback
import random
random.seed(0)
import argparse

import rule
from loader import Loader
from rewriter import Rewriter
from evaluator import Evaluator
from ProveVerifier import ProveVerifier
from TestVerifier import TestVerifier
from mo_sql_parsing import format
from tqdm import tqdm
import time
from utils import generate_query_param_rewrites, exp_recorder

from config import CONNECT_MAP, FileType, get_filename

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', default='redmine')
    parser.add_argument('--prove', action='store_true')
    parser.add_argument('--db', action='store_true', \
            help='only use db constraints to perform optimization')
    args = parser.parse_args()
    
    appname =  args.app
    if args.prove:
        query_filename = get_filename(FileType.TEST_PROVE_Q, appname)
    else:
        query_filename = get_filename(FileType.RAW_QUERY, appname) 
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    offset = 0
    query_cnt = 10000
    rules = [rule.RemovePredicate, rule.RemoveDistinct, rule.RewriteNullPredicate,
             rule.AddLimitOne, rule.RemoveJoin, rule.ReplaceOuterJoin]
    constraints = Loader.load_constraints(constraint_filename)
    if args.db:
        print("========Only use DB constraints to perform optimization======")
        print("[Before filtering DB constraints] ", len(constraints))
        constraints = [c for c in constraints if c.db == True]
        print("[After filtering DB constraints] ", len(constraints))
    queries = Loader.load_queries(query_filename, offset, query_cnt)
    rewriter = Rewriter()
    rewriter.set_rules(rules)

    rewrite_time = []
    rewrite_cnt = 0
    total_candidate_cnt = []
    dump_counter = False # only dump counter example

    enumerate_time = 0
    get_cost_time = 0
    run_test_time = 0
    sort_time = 0
    dump_time = 0
    for q in tqdm(queries):
        start = time.time()
        # =================Enumerate Candidates================
        rewritten_queries = []
        try:
            rewritten_queries = rewriter.rewrite(constraints, q)
        except:
            print("[Error rewrite]", q.q_raw)
            print(traceback.format_exc())
            continue
        rewrite_time.append(time.time() - start)
        if len(rewritten_queries) == 0:
            continue
            
        end = time.time()
        enumerate_time += end-start
        start = end
        # ======== Estimate cost and retain those with lower cost than original ======
        rewritten_queries_lower_cost = []
        # replace placeholder with actual parameters for org and rewrites
        connect_str = CONNECT_MAP[appname]
        succ = generate_query_param_rewrites(q, rewritten_queries, connect_str)
        if not succ:
            continue
        # remove rewrites that fail to generate parameters
        rewritten_queries = [rq for rq in rewritten_queries if rq.q_raw_param is not None]
        # retain rewrites with lower cost
        try:
            org_cost = Evaluator.evaluate_cost(q.q_raw_param, connect_str)
        except:
            print("[Error] Fail to evaluate %s" % q.q_raw_param)
            continue
        
        for rq in rewritten_queries:
            try:
                estimate_cost = Evaluator.evaluate_cost(rq.q_raw_param, connect_str) 
                if estimate_cost < 2 * org_cost:
                    rq.estimate_cost = estimate_cost 
                    rewritten_queries_lower_cost.append(rq)
                else:
                    print("[Error] rewrite get slower")
                    print("[Org] %f %s" % (org_cost, q.q_raw_param))
                    print("[Rewrite] %f %s" % (estimate_cost, rq.q_raw_param))
            except:
                # rewrite might have wrong syntax
                continue
        if len(rewritten_queries_lower_cost) == 0:
            continue
        
        end = time.time()
        get_cost_time += end-start
        start = end
        # ======== Run test and retain those that pass =========
        rewritten_queries_lower_cost_after_test = []
        not_eq_qs = []
        # use tests to check equivalence
        rewritten_queries_lower_cost_after_test, not_eq_qs = TestVerifier().verify(appname, q, constraints, rewritten_queries_lower_cost)
        if dump_counter:
            if len(not_eq_qs) == 0:
                continue
            # dump counter examples
            ProveVerifier().verify(appname, q, constraints, not_eq_qs, rewrite_cnt, counter=True)
            rewrite_cnt += 1
            continue
         
        if len(rewritten_queries_lower_cost_after_test) == 0:
            continue
       
        end = time.time()
        run_test_time += end-start
        start = end
        # ========= Sort rewrites that pass tests ============
        # Sort the list in place
        rewritten_queries_lower_cost_after_test.sort(key=lambda x: x.estimate_cost, reverse=False)
        
        end = time.time()
        sort_time += end-start
        start = end
        # ========== Dump outputs to cosette ==========
        rewrite_cnt += 1
        total_candidate_cnt.append(len(rewritten_queries_lower_cost_after_test))
        ProveVerifier().verify(appname, q, constraints, rewritten_queries_lower_cost_after_test, rewrite_cnt)

        end = time.time()
        dump_time += end-start
    
    exp_recorder.record("candidate info",  total_candidate_cnt)
    print("Rewrite Number %d" % rewrite_cnt)
    print("Average # of candidates %f" % (sum(total_candidate_cnt) / len(total_candidate_cnt)))
    print("Total time enumerating query rewrites: %d" % enumerate_time)
    print("Total time estimating cost of rewrites: %d" % get_cost_time)
    print("Total time running tests for verification: %d" % run_test_time)
    print("Total time sorting verified queries: %d" % sort_time)
    print("Total time dumping outputs: %d" % dump_time)
