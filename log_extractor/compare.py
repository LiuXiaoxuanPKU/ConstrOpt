# 1. postgreSQL explain original queries --> get execution plan
# 2. read constraints from constraints/redmine, add constraints to database
# 3. postgreSQL explain again --> get execution plan
# 4. compare and count the number of different plans, print statistics

# Usage: python3 compare.py app_name
# Example: python3 compare.py redmine
# prerequisie: pip3 install psycopg2; if you are using M1 chip, use conda environment: conda install psycopg2

import sys
import psycopg2
import pickle
import json
sys.path.append('./../autrite')
import benchmark
import loader
import constraint
from config import CONNECT_MAP


# return queries in example_app.pk file 
def scan_queries(app_name) -> list:
    filename = "../queries/{}/{}.pk".format(app_name, app_name)
    queries = loader.Loader.load_queries_raw(filename, cnt=1000)
    queries = benchmark.generate_query_params(queries, CONNECT_MAP[app_name])
    # make sure that all qeries are unique
    queries = list(set(queries))
    return queries


# return a list of dumped query plan from postgreSQL EXPLAIN
def view_query_plan(queries, conn) -> list:
    cur = conn.cursor()
    plans = []
    for q in queries:
        try: 
            sql = "explain {};".format(q)
            cur.execute(sql)
            plans.append(cur.fetchall()[0])
        except Exception as e:
            print("error sql is {}". format(sql))
            print("error is {}".format(e))
            exit(0)
    return plans

# read in constraints
def load_constraints(constraint_file) -> list:
    constraints = loader.Loader.load_constraints(constraint_file)
    return constraints

# add constraints to database 
def add_constraint(constraints):
    cur = conn.cursor()
    # elch tuple in roll_back_info is (0, table_name, constraint_name) or 
    # (1, table_name_for_not_null, column_name for not_null)
    roll_back_info = []
    for c in constraints:
        if c.table is None:
            continue
        elif isinstance(c, constraint.UniqueConstraint):
            constraint_name = "unique_%s_%s" % (c.table, c.field) 
            roll_back_info.append((0, c.table, constraint_name))
            fields = [c.field] + c.scope
            fields = ', '.join(fields)
            sql1 = "ALTER TABLE {} ADD COLUMN IF NOT EXISTS {} INTEGER; ALTER TABLE {} DROP CONSTRAINT IF EXISTS {};".format(
                c.table, c.field, c.table, constraint_name) 
            sql2 = "ALTER TABLE %s ADD CONSTRAINT %s UNIQUE (%s);" % (
                c.table, constraint_name, fields)
        elif isinstance(c, constraint.PresenceConstraint):
            roll_back_info.append((1, c.table, c.field))
            sql1 = "ALTER TABLE {} ADD COLUMN IF NOT EXISTS {} INTEGER;".format(c.table, c.field)
            sql2 = "ALTER TABLE %s ALTER COLUMN %s SET NOT NULL;" % (c.table, c.field)
        elif isinstance(c, constraint.NumericalConstraint):
            constraint_name = "numerical_%s_%s" % (c.table, c.field)
            roll_back_info.append((0, c.table, constraint_name))
            sql1 = "ALTER TABLE {} ADD COLUMN IF NOT EXISTS {} INTEGER; ALTER TABLE {} DROP CONSTRAINT IF EXISTS {};".format(
                c.table, c.field, c.table, constraint_name)
            if c.min is not None and c.max is None:
                sql2 = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} > {});".format(
                    c.table, constraint_name, c.field, c.min)
            elif c.min is None and c.max is not None:
                sql2 = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} < {});".format(
                    c.table, constraint_name, c.field, c.max)
            else:
                sql2 = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} > {} AND {} < {});".format(
                    c.table, constraint_name, c.field, c.min, c.field, c.max)
        try:
            cur.execute(sql1)
            cur.execute(sql2)
            conn.commit()
        except (psycopg2.errors.NotNullViolation, 
        psycopg2.errors.UniqueViolation, 
        psycopg2.errors.SyntaxError) as e:
            print(sql1)
            print(sql2)
            print(type(e))
            conn.rollback()
    return roll_back_info
            
    

def roll_back(conn, roll_back_info):
    cur = conn.cursor()
    for tuple in roll_back_info:
        # drop constraint sql case
        if tuple[0] == 0:
            table_name = tuple[1]
            constraint_name = tuple[2]
            sql = "ALTER TABLE {} DROP CONSTRAINT IF EXISTS {};".format(table_name, constraint_name)
        # drop not null constraint case 
        else:
            table_name = tuple[1]
            column_name = tuple[2]
            sql = "ALTER TABLE {} ADD COLUMN IF NOT EXISTS {} INTEGER; ALTER TABLE {} ALTER COLUMN {} DROP NOT NULL;".format(
                table_name, column_name, table_name, column_name)
        try:
            cur.execute(sql)
            conn.commit()
        except (psycopg2.errors.NotNullViolation, 
        psycopg2.errors.UniqueViolation, 
        psycopg2.errors.SyntaxError, psycopg2.errors.InFailedSqlTransaction) as e:
            print(sql)
            print(type(e))
            conn.rollback()

def count_diff(old_plans, new_plans):
    assert(len(old_plans) == len(new_plans))
    cnt = 0
    n = len(old_plans)
    for i in range(n):
        if old_plans[i] != new_plans[i]:
            cnt += 1
    print("out of {} queries, {} are rewrite by postgreSQD after constraints".format(n, cnt))



if __name__ == "__main__": 
    app_name = sys.argv[1]
    queries = scan_queries(app_name)
    # Connect to Database
    try:
        conn = psycopg2.connect(database="redmine", user=app_name, password="my_password")
    except ImportError:
        print("If you are using macOS with M1 chip, use conda environemnt to run.")
    # get postgreSQL query plan before adding constraints 
    old_plans = view_query_plan(queries, conn)
    # read in constraints, "./../constraints/redmine"
    constraints = load_constraints("./../constraints/%s" % app_name)
    # add constraints to database
    roll_back_info = add_constraint(constraints)
    # get postgreSQL query plan after adding constraints
    new_plans = view_query_plan(queries, conn)
    # roll back database constraints
    roll_back(conn, roll_back_info)
    # count different query plans 
    count_diff(old_plans, new_plans)
    conn.commit()
    conn.close()


    
    