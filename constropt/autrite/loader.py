import pickle
import queue
from mo_sql_parsing import parse, format
import json
import constraint
from config import RewriteQuery

class Loader:
    @staticmethod
    def load_constraints(filename):
        constraints = []
        classnodes = json.load(open(filename, 'r'))
        for classnode in classnodes:
            constraints_obj = classnode['constraints']
            for obj in constraints_obj:
                c = None
                if obj["^o"] == "LengthConstraint":
                    c = constraint.LengthConstraint(
                        classnode['table'], obj['field_name'], obj['db'], obj['min'], obj['max'])
                elif obj["^o"] == "UniqueConstraint":
                    if len(obj["cond"]) > 0:
                        continue
                    if obj['type'] == 'pk':
                        continue
                    c = constraint.UniqueConstraint(
                        classnode['table'], obj['field_name'], obj['db'], obj["type"], cond=None)
                elif obj["^o"] == "PresenceConstraint":
                    c = constraint.PresenceConstraint(
                        classnode['table'], obj['field_name'], obj['db'])
                elif obj["^o"] == "InclusionConstraint":
                    c = constraint.InclusionConstraint(
                        classnode['table'], obj['field_name'], obj['db'], obj['values'])
                elif obj["^o"] == "FormatConstraint":
                    c = constraint.FormatConstraint(
                        classnode['table'], obj['field_name'], obj['db'], obj['format'])
                elif obj["^o"] == "NumericalConstraint":
                    if obj['min'] is None and obj['max'] is None:
                        continue
                    c = constraint.NumericalConstraint(
                        classnode['table'], obj['field_name'], obj['db'], obj['min'], obj['max'])
                elif obj["^o"] == "ForeignKeyConstraint":
                    c = constraint.ForeignKeyConstraint(
                        classnode['table'], obj['fk_column_name'], obj['db'], obj['class_name']
                    )
                else:
                    print("[Error] Unsupport constraint type ", obj)
                    continue
                constraints.append(c)
            constraints = list(set(constraints))
        print("======================Load %d constraints" % len(constraints))
        return constraints

    @staticmethod
    def load_queries_raw(filename, offset, cnt):
        if filename.endswith("pk"):
            with open(filename, 'rb') as f:
                lines = pickle.load(f)
                if isinstance(lines[0], str):
                    lines = lines
                else:
                    lines = [l[1] for l in lines]
        elif filename.endswith("sql"):
            with open(filename, 'r') as f:
                lines = f.readlines()
        else:
            raise NotImplementedError("Does not support file %s as query input" % (filename))
        total_raw_queries = len(lines)
        lines = list(set(lines))
        unique_raw_queries = len(lines)
        print("Total # of raw queries: ", total_raw_queries)
        print("Total # of unique raw queries: ", unique_raw_queries)

        lines.sort(key=len)
        lines = lines[offset:offset+cnt]
        return lines

    @staticmethod
    def load_queries(filename, offset=0, cnt=500):
        lines = Loader.load_queries_raw(filename, offset, cnt)
        rewrite_qs = []
        fail_raw_queries = []
        for line in lines:
            try:
                q_obj = parse(line)
                q = RewriteQuery(format(q_obj), q_obj)
                rewrite_qs.append(q)
            except:
                fail_raw_queries.append(line)
        print("======================[Success] Parse unique queries %d" % len(rewrite_qs))
        print("======================[Fail]    Parse %d queries" % len(fail_raw_queries))
        return rewrite_qs
