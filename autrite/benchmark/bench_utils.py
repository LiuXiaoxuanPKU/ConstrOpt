import sys, os
from tqdm import tqdm
import traceback
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config import CONNECT_MAP
from evaluator import Evaluator
import constraint
from utils import generate_query_param_single

def install_constraints(constraints, appname):
    installed_constraints = []
    print("=============Install constraints============")
    for c in tqdm(constraints):
        if c.table is None:
            continue
        elif isinstance(c, constraint.UniqueConstraint):
            if c.type == 'pk':
                continue
            constraint_name = str(c)
            roll_back_info = (c, constraint_name)
            fields = list(c.field)
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
                install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} >= {});".format(
                    c.table, constraint_name, c.field, c.min)
            elif c.min is None and c.max is not None:
                install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} <= {});".format(
                    c.table, constraint_name, c.field, c.max)
            else:
                install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} >= {} AND {} <= {});".format(
                    c.table, constraint_name, c.field, c.min, c.field, c.max)
        else:
            continue
        try:
            Evaluator.evaluate_query("ALTER TABLE {} DROP CONSTRAINT IF EXISTS {}".format(c.table, constraint_name), CONNECT_MAP[appname])
            Evaluator.evaluate_query(install_sql, CONNECT_MAP[appname])
            installed_constraints.append(roll_back_info)
        except Exception as e:
            print(install_sql)
            print(traceback.format_exc())
            exit(0)
    print("Install constraints success/all: %d/%d" % (len(installed_constraints), len(constraints)))
    return installed_constraints            

# does not catch exception here, roll back shoud succeed
def roll_back(installed_constraints, appname):
    print("=============Rollback Constraint===============")
    for roll_back_info in installed_constraints:
        c, constraint_name = roll_back_info
        if type(c) in [constraint.NumericalConstraint, constraint.UniqueConstraint]:
            drop_sql = "ALTER TABLE %s DROP CONSTRAINT IF EXISTS %s;" % (c.table, constraint_name)
        elif type(c) in [constraint.PresenceConstraint]:
            drop_sql = "ALTER TABLE %s ALTER COLUMN %s DROP NOT NULL;" %(c.table, c.field)
        Evaluator.evaluate_query(drop_sql, CONNECT_MAP[appname])

def get_valid_queries(queries, connect_str):
    print("==========Get Valid Queries============")
    valid_queries = []
    for q in tqdm(queries):
        try:
            q_param = generate_query_param_single(q.q_raw, connect_str, {})
            if q_param is None:
                continue
            Evaluator.evaluate_query(q_param, connect_str)
            valid_queries.append(q)
        except:
            print(traceback.format_exc())
            pass
    print("Total queries: %d, valid queries: %d" % (len(queries), len(valid_queries)))
    return valid_queries
