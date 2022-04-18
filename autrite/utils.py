import os
import json, random, hashlib
from collections import OrderedDict
from constraint import UniqueConstraint
from evaluator import Evaluator

def test_unorder_list_eq(l1, l2):
    if len(l1) != len(l2):
        return False
    sort_l1 = sorted(l1)
    sort_l2 = sorted(l2)
    return sort_l1 == sort_l2
    
def test_constraint_overlap(c1, c2):
    if type(c1) != type(c2):
        return False
    eq = True
    eq = eq and (c1.table == c2.table)
    
    if isinstance(c1, UniqueConstraint):
        eq = eq and (c1.cond == c2.cond)
        if isinstance(c1.field, str):
            c1_field = [c1.field]
        else:
            c1_field = c1.field
        if isinstance(c2.field, str):
            c2_field = [c2.field]
        else:
            c2_field = c2.field
        eq = eq and test_unorder_list_eq(c1.scope + c1_field, c2.scope +c2_field)
    else:
        print("[Error] Unimplemented constraint overlap for %s" % type(c1))
    return eq
        
        
def load_json_queries(filename):
    rewrite_file =  filename
    if not os.path.isfile(rewrite_file):
        print("[Error] Please first generate rewrite")
    with open(rewrite_file, "r") as f:
        lines = f.readlines()  
    return [json.loads(line) for line in lines]

def get_str_hash(str):
    return hashlib.sha256(str.encode('utf-8')).hexdigest()

def test_query_result_equivalence(r1, r2):    
    if len(r1) != len(r2):
        return False

    r1_sort = sorted(r1, key=lambda x: x[0])
    r2_sort = sorted(r2, key=lambda x: x[0])
    for e1, e2 in zip(r1_sort, r2_sort):
        if e1 != e2:
            return False
    return True
        
def get_field_value(table_field, cache, connect_str, field_idx = -1):
    if table_field.startswith("LOWER"):
        table_field = table_field[6:-1]
    
    if field_idx != -1:
        cache_name = table_field + "_%d" % field_idx
    else:
        cache_name = table_field
        
    if cache_name in cache:
        return cache[cache_name]
    try:
        table, field = table_field.split('.')
        SQL = "SELECT %s FROM %s ORDER BY RANDOM() LIMIT 1" % (field, table)
        ret =  Evaluator.evaluate_query(SQL, connect_str)
    except:
        return []
    cache[cache_name] = ret
    return ret

def generate_query_param_single(q, connect_str, cache):
    if '$' not in q:
        return q
    tokens = q.split(" ")
    for i, token in enumerate(tokens):
        if '$' in token:
            if tokens[i-1] == "LIMIT":
                if 'limit' in cache:
                    v = cache['limit']
                else:
                    v = str(random.randint(1, 10))
                    cache['limit'] = v
                tokens[i] = v
                
            elif tokens[i-1] == "OFFSET":
                tokens[i] = "1"
            elif tokens[i-1] in ["=", "!=", ">", "<", "<>"]:
                re = get_field_value(tokens[i-2], cache, connect_str)
                if len(re) == 0 or re[0][0] is None:
                    return None
                tokens[i] = re[0][0]
                if isinstance(tokens[i], str):
                    tokens[i] = "'" + tokens[i] + "'"
                else:
                    tokens[i] = str(tokens[i])
            elif tokens[i-1] == "IN":
                end_idx = i
                while ")" not in tokens[end_idx]:
                    end_idx += 1
                for j in range(i, end_idx + 1):
                    re = get_field_value(tokens[i-2], cache, connect_str, j)
                    if len(re) == 0 or re[0][0] is None:
                        return None
                    tokens[j] = re[0][0]
                    if isinstance(tokens[j], str):
                        tokens[j] = "'" + tokens[j] + "'"
                    else:
                        tokens[j] = str(tokens[j])
                    tokens[j] += ","
                tokens[i] = "(" + tokens[i]
                tokens[end_idx] =  tokens[end_idx][:-1] + ")"
    q = " ".join(tokens)
    return q

# the rewrites and q should have the sample parameters
# return False if fails to generate parameters for the original query, otherwise True
def generate_query_param_rewrites(q, rewrites, connect_str):
    cache = {}
    q.q_raw_param = generate_query_param_single(q.q_raw, connect_str, cache)
    if q.q_raw_param is None:
        return False
    for rq in rewrites:
        rq.q_raw_param = generate_query_param_single(rq.q_raw, connect_str, cache)
    return True
        
def generate_query_params(queries, connect_str, cache):
    param_qs = []
    for q in queries:
        q_param = generate_query_param_single(q, connect_str, cache)
        if q_param is not None:
            param_qs.append(q_param)
    return param_qs

class GlobalExpRecorder:
    def __init__(self):
        self.val_dict = OrderedDict()

    def record(self, key, value):
        self.val_dict[key] = value

    def dump(self, filename):
        with open(filename, "a") as fout:
            fout.write(json.dumps(self.val_dict) + '\n')
        # print("Save exp results to %s" % filename)

    def clear(self, filename):
        open(filename, 'w').close()
        

exp_recorder = GlobalExpRecorder()