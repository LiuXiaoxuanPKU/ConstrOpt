from tqdm import tqdm
from evaluator import Evaluator
from utils import generate_query_param_single, test_query_result_equivalence
from mo_sql_parsing import format
from config import CONNECT_MAP, RewriteQuery

class TestVerifier:
    def __init__(self) -> None:
        pass

    def get_connect_str(self, appname):
        return CONNECT_MAP[appname]

    def verify(self, appname, q, constraints, rewritten_queries, show_progress=False):
        if q.q_raw_param is None:
            print("[Error] Fail to evaluete %s, missing parameters" % q.q_raw_param)
            exit(0)
            
        connect_str = self.get_connect_str(appname)
        try:
            org_result = Evaluator.evaluate_query(q.q_raw_param, connect_str)
        except:
            # print("Fail to execute %s" % format(q))
            return [], []
        
        eq_qs = []
        not_eq_qs = []
        if show_progress:
            iter = tqdm(rewritten_queries)
        else:
            iter = rewritten_queries
        for rq in iter:
            if rq.q_raw_param is None:
                print("[Error] Fail to evaluete %s, missing parameters" % rq.q_raw_param)
                exit(0)
            try:
                # rewrite might be wrong, so we need try except error here
                rq_result = Evaluator.evaluate_query(rq.q_raw_param, connect_str)
                if test_query_result_equivalence(org_result, rq_result):
                    eq_qs.append(rq)
                else:
                    not_eq_qs.append(rq)
            except:
                # print("Fail to execute %s" % format(rq))
                pass
        return eq_qs, not_eq_qs




