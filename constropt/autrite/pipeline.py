import traceback
import random
random.seed(0)
import argparse

import rule
from loader import Loader
from rewriter import Rewriter
from evaluator import Evaluator
from Provedumper import ProveDumper
from TestVerifier import TestVerifier
from mo_sql_parsing import format, parse
from tqdm import tqdm
import time
from utils import generate_query_param_rewrites, generate_query_param_single

from config import CONNECT_MAP, FileType, RewriteQuery, get_filename

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', default='redmine')
    parser.add_argument('--prove', action='store_true')
    parser.add_argument('--db', action='store_true', \
            help='only use db constraints to perform optimization')
    parser.add_argument('--counter', action='store_true', help="dump counter example")
    args = parser.parse_args()
    
    appname =  args.app
    if args.prove:
        query_filename = get_filename(FileType.TEST_PROVE_Q, appname)
    else:
        query_filename = get_filename(FileType.RAW_QUERY, appname) 
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    offset = 0
    query_cnt = 1000000
    rules = [rule.RemovePredicate, rule.RemoveDistinct, rule.RewriteNullPredicate,
             rule.RemoveJoin, rule.ReplaceOuterJoin, rule.AddLimitOne]
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
    dump_counter = args.counter # only dump counter example

    enumerate_cnt = 0
    lower_cost_cnt = 0
    lower_cost_pass_test_cnt = 0 
    connect_str = CONNECT_MAP[appname]
    
    enumerate_time = 0
    get_cost_time = 0
    run_test_time = 0
    sort_time = 0
    dump_time = 0
    
    for q in tqdm(queries):
        with open("%s_stats" % appname, "w") as f:
            f.write("%d, %d, %d" % (enumerate_cnt, lower_cost_cnt, lower_cost_pass_test_cnt))
        # =================Try to generate param first========
        try:
            q_raw = generate_query_param_single(q.q_raw, connect_str, {})
            Evaluator.evaluate_query(q_raw, connect_str)
        except:
            continue 

        start = time.time()
        # =================Enumerate Candidates================
        enumerate_queries = []
        try:
            enumerate_queries = rewriter.rewrite(constraints, q)
        except:
            print("[Error rewrite]", q.q_raw)
            print(traceback.format_exc())
            continue
        rewrite_time.append(time.time() - start)
        if len(enumerate_queries) == 0:
            continue
        enumerate_cnt += 1
        end = time.time()
        enumerate_time = end-start
        start = end  

        # ======== Estimate cost and retain those with lower cost than original ======
        rewritten_queries_lower_cost = []
        # replace placeholder with actual parameters for org and rewrites
        rewritten_queries = enumerate_queries
        succ = generate_query_param_rewrites(q, rewritten_queries, connect_str)
        if not succ:
            continue
        # remove rewrites that fail to generate parameters
        rewritten_queries = [rq for rq in rewritten_queries if rq.q_raw_param is not None]
        if len(rewritten_queries) == 0:
            continue
        # retain rewrites with lower cost
        try:
            org_cost = Evaluator.evaluate_cost(q.q_raw_param, connect_str)
        except:
            print("[Error] Fail to evaluate %s" % q.q_raw_param)
            continue
        
        for rq in rewritten_queries:
            try:
                estimate_cost = Evaluator.evaluate_cost(rq.q_raw_param, connect_str) 
                if estimate_cost <= org_cost:
                    rq.estimate_cost = estimate_cost 
                    rewritten_queries_lower_cost.append(rq)
                else:
                    print("[Warning] rewrite get slower")
                    print("[Org] %f %s" % (org_cost, q.q_raw_param))
                    print("[Rewrite] %f %s" % (estimate_cost, rq.q_raw_param))
            except:
                # rewrite might have wrong syntax
                continue
        if len(rewritten_queries_lower_cost) == 0:
            continue
        lower_cost_cnt += 1
        
        end = time.time()
        get_cost_time = end-start
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
            ProveDumper().verify(appname, q, constraints, not_eq_qs, rewrite_cnt, counter=True)
            rewrite_cnt += 1
            continue
         
        if len(rewritten_queries_lower_cost_after_test) == 0:
            continue
        lower_cost_pass_test_cnt += 1
       
        end = time.time()
        run_test_time = end - start
        
        # ========= Sort rewrites that pass tests ============
        # Sort the list in place
        rewritten_queries_lower_cost_after_test.sort(key=lambda x: x.estimate_cost, reverse=False)
        
        # ========== Dump outputs to cosette ==========
        rewrite_cnt += 1
        total_candidate_cnt.append(len(rewritten_queries_lower_cost_after_test))
        ProveDumper().verify(appname, q, constraints, rewritten_queries_lower_cost_after_test, rewrite_cnt)
   
    print("Average # of candidates %f" % (sum(total_candidate_cnt) / len(total_candidate_cnt)))
    print("Enumerate count %d" % enumerate_cnt)
    print("Lower cost cnt %d" % lower_cost_cnt)
    print("Lower cost pass test %d" % lower_cost_pass_test_cnt)
