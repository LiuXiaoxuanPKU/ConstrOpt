import psycopg2

JIT = "on"
class Evaluator:
    @staticmethod
    def evaluate_query(q, connect_string):
        # Connect to an existing database
        with psycopg2.connect(connect_string) as conn:
            # Open a cursor to perform database operations
            with conn.cursor() as cur:
                # Execute a command: explain query
                cur.execute(q)
                # Fetch result
                if cur.description is not None:
                    explain_fetched = cur.fetchall()
                else: # no results to fetch
                    explain_fetched  = []
                cur.close()
                return explain_fetched

    @staticmethod
    def evaluate_actual_time(q, connect_string):
        # Connect to an existing database
        with psycopg2.connect(connect_string) as conn:
            # Open a cursor to perform database operations
            with conn.cursor() as cur:
                # Execute a command: explain query
                cur.execute("set jit=%s" % JIT)
                cur.execute("EXPLAIN ANALYZE " + q)
                # Fetch result
                explain_fetched = cur.fetchall()[-1]
                # Parse actual runtime
                actual_time = float(explain_fetched[0].split(':')[-1].split('ms')[0])
                cur.close()
                return actual_time

    @staticmethod
    def evaluate_cost(q, connect_string):
        # Connect to an existing database
        with psycopg2.connect(connect_string) as conn:
            # Open a cursor to perform database operations
            with conn.cursor() as cur:
                # Execute a command: explain query
                cur.execute("EXPLAIN " + q)
                # Fetch result
                explain_fetched = cur.fetchone()
                # Parse cost
                cost = float(explain_fetched[0].split('(')[1].split('..')[1].split(' ')[0])
                cur.close()
                return cost

    @staticmethod
    def evaluate_cost_batch(q_list, connect_string):
        # Connect to an existing database
        with psycopg2.connect(connect_string) as conn:
            # Open a cursor to perform database operations
            with conn.cursor() as cur:
                costs = []
                for q in q_list:
                    # Execute a command: explain query
                    cur.execute("EXPLAIN " + q)
                    # Fetch results
                    explain_fetched = cur.fetchone()
                    # Parse cost
                    costs.append(float(explain_fetched[0].split('(')[1].split('..')[1].split(' ')[0]))
                cur.close()
                return costs
