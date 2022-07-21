import os, sys, random
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from evaluator import Evaluator
import psycopg2

CONNECT_STRING = "user=postgres password=xx"

def test_evaluate_query():
    eva = Evaluator()
    q = "INSERT into a VALUES(%d, %d, 'test')" % \
                (random.randint(0, 1000), random.randint(0, 1000))
    print("Exec result: ", eva.evaluate_query(q, CONNECT_STRING))
    q = "SELECT * from a"
    print("Exec result: ", eva.evaluate_query(q, CONNECT_STRING)) 

def test_evaluate_actual():
    eva = Evaluator()
    q = "SELECT * FROM a as a1 INNER JOIN a as a2 ON a1.name = a2.name"
    print("Exec time: ", eva.evaluate_actual_time(q, CONNECT_STRING))

def test_evaluate_cost():
    eva = Evaluator()
    q = "SELECT * FROM a as a1 INNER JOIN a as a2 ON a1.name = a2.name"
    assert(eva.evaluate_cost(q, CONNECT_STRING) == 26.48)

def test_evaluate_cost_batch():
    eva = Evaluator()
    q_list = ["SELECT * FROM a as a1 INNER JOIN a as a2 ON a1.name = a2.name",
    "SELECT * FROM a",
    "SELECT a2.name FROM a as a1 INNER JOIN a as a2 ON a1.product_id = a2.user_id"]
    assert(eva.evaluate_cost_batch(q_list, CONNECT_STRING) == [26.48, 11.4, 26.48])

if __name__ == "__main__":
    with psycopg2.connect(CONNECT_STRING) as conn:
        with conn.cursor() as cur:
            cur.execute("""CREATE TABLE IF NOT EXISTS a (
                user_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                name VARCHAR(255) NOT NULL,
                PRIMARY KEY(user_id, product_id)
            )""")
            conn.commit()
            cur.close()
    test_evaluate_query()
    test_evaluate_actual()
    test_evaluate_cost()
    test_evaluate_cost_batch()