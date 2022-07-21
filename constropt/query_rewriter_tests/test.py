import json
import traceback
from mo_sql_parsing import parse, format

import sys
sys.path.insert(0, '/home/ubuntu/ConstrOpt/constropt')
from query_rewriter import Rewriter
from query_rewriter.constraint import *


class RewriteTestor:
    def __init__(self, filename) -> None:
        self.filename = filename
        self.data = json.load(open(filename, "r"))
        self.r = Rewriter()
        self.constraint_dic = {
            "unique": UniqueConstraint,
            "numerical": NumericalConstraint
        }
        self.rewrite_dic = {
            "add_limit_one": self.r.add_limit_one,
            "remove_predicate_numerical": self.r.remove_predicate_numerical,
            "remove_distinct": self.r.remove_distinct
        }

    def create_constraint(self, constraint_obj):
        if not isinstance(constraint_obj, list):
            constraint_obj = [constraint_obj]
        constraints = []
        for obj in constraint_obj:
            args = tuple(obj["args"].values())
            constraints.append(self.constraint_dic[obj["type"]](*args))
        return constraints

    def run_by_ids(self, ids):
        for record in self.data:
            if record['id'] not in ids:
                continue
            self.run(record)

    def run_all(self):
        valid_cnt = 0
        print("=====Start Test=====")
        print("Test file", self.filename)
        for record in self.data:
            ok = self.run(record)
            if ok:
                valid_cnt += 1
        print("=====Finish Test=====")
        print("Pass cases: %d/%d" % (valid_cnt, len(self.data)))

    def run(self, record):
        c = self.create_constraint(record["constraint"])
        before_q = parse(record['before'])
        after_q = parse(record['after'])
        ok = True
        try:
            rewrite_type, rewrite_q = self.rewrite_dic[record["type"]](before_q,
                                                                       c)
            can_rewrite = len(rewrite_type) > 0
            if can_rewrite != record["can_rewrite"]:
                print("[Test Fail] Can rewrite: expect %s, get %s, id %d" %
                      (record["can_rewrite"], can_rewrite, record["id"]))
                ok = False
            if format(rewrite_q) != format(after_q):
                print("[Test Fail] Error rewrite query: expect %s, get %s, id: %d" % (
                    format(after_q), format(rewrite_q), record["id"]))
                ok = False
        except Exception as e:
            print("%d throw exception %s" %
                  (record["id"], traceback.print_exc()))
            ok = False
        return ok


if __name__ == "__main__":
    testor = RewriteTestor("/home/ubuntu/ConstrOpt/constropt/query_rewriter_tests/cases/add_limit_one.json")
    testor.run_all()

    testor = RewriteTestor("/home/ubuntu/ConstrOpt/constropt/query_rewriter_tests/cases/remove_predicate_numerical.json")
    testor.run_all()

    testor = RewriteTestor("/home/ubuntu/ConstrOpt/constropt/query_rewriter_tests/cases/remove_distinct.json")
    testor.run_all()
