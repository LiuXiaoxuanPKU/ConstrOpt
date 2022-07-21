import copy
import z3
from constraint import NumericalConstraint
from mo_sql_parsing import parse, format
from config import PRIORITY_MAP, REWRITE_LIMIT

class Rule:
    def __init__(self, cs) -> None:
        self.constraint = cs

    def __str__(self) -> str:
        return self.name

    def __eq__(self, __o: object) -> bool:
        return self.__hash__() == __o.__hash__()
    
    def __gt__(self, other):
        return PRIORITY_MAP[self.name] < PRIORITY_MAP[other.name]
        
    def __hash__(self) -> int:
        if type(self) in [AddPredicate, RewriteNullPredicate]:
            hash_v = str(type(self)) + str(hash(self.constraint))
        else: # only keep rule type
            hash_v = str(type(self))
        return hash(hash_v)

    @staticmethod
    def keyword_nested(keyword, q):
        if keyword in ["select", "select_distinct"]:
            # TODO: handle multiple select items
            if keyword in q and isinstance(q[keyword], dict) \
                            and isinstance(q[keyword]['value'], dict) :
                nested_dict =  q[keyword]['value']
                keys = list(nested_dict.keys())
                # only handle select (select )
                # rule out select aggregate()
                if len(keys) >= 1 and keys[0] == 'select' or keys[0] == 'select_distinct':
                    return q[keyword]['value']
                return None
        
        # rule out select abs as a case
        if keyword == 'from' and 'from' in q and isinstance(q['from'], dict) and len(q['from']) == 2 and \
            'value' in q['from'] and 'name' in q['from']:
                return None
            
        if keyword == 'from' and 'from' in q and isinstance(q['from'], dict):
            return q['from']

        return None

    @staticmethod
    def replace_keyword_nested(org_q, keyword, sub_q):
        if keyword == "select" or keyword == 'select_distinct':
            org_q[keyword]['value'] = sub_q
        elif  keyword in ['from', 'where', 'having']:
            org_q[keyword] = sub_q
        return org_q

    @staticmethod
    def comb(rewritten_items):
        if len(rewritten_items) == 0:
            return [[]]
        ret = []
        partial_results = Rule.comb(rewritten_items[:len(rewritten_items) - 1])
        for e in rewritten_items[-1]:
            for r in partial_results:
                ret.append(r + [e])
        return ret

    def get_name(self):
        return str(self)
        
    # rewrite the entire query, call apply_single
    # handle nested queries
    def apply(self, q):
        if not isinstance(q, dict):
            return []

        # subquery happens in WHERE, FROM, SELECT, HAVING
        rewritten_qs = [q]
        outer_rewritten_q =  self.apply_single(q)
        if len(outer_rewritten_q):
            rewritten_qs += outer_rewritten_q

        if len(rewritten_qs) > REWRITE_LIMIT:
            return rewritten_qs[1:]
        
        # SELECT, FROM
        for k in ["select", "select_distinct", "from"]:
            tmp_rewritten_qs = []
            for rq in rewritten_qs:
                keyword_sub = Rule.keyword_nested(k, rq)
                if keyword_sub:
                    rewritten_keyword_subs = self.apply(keyword_sub)
                    for sub in rewritten_keyword_subs:
                        rewritten_q = Rule.replace_keyword_nested(copy.deepcopy(rq), k, sub)
                        tmp_rewritten_qs.append(rewritten_q)
                        if len(rewritten_qs) + len(tmp_rewritten_qs) > REWRITE_LIMIT:
                            rewritten_qs += tmp_rewritten_qs
                            return rewritten_qs[1:]
                        
            rewritten_qs += tmp_rewritten_qs
            if len(rewritten_qs) > REWRITE_LIMIT:
                return rewritten_qs [1:]
        
        def rewrite_cond(cond):
            rewritten_cond = []
            if not isinstance(cond, dict):
                return []
            assert(len(cond) == 1)
            op = list(cond.keys())[0]
            if op == "and" or op == "or":
                rewritten_items = []
                for item in cond[op]:
                    rewritten_items.append([item] + rewrite_cond(item))
                    
                re = Rule.comb(rewritten_items)[1:]
                for r in re:
                    rewritten_cond.append({op:copy.deepcopy(r)})
                return rewritten_cond
            elif op in ["exists", "missing"]:
                v = cond[op]
                # nested query
                if isinstance(v, dict) and ('select' in v):
                    rewritten_vs = self.apply(v)
                    for r1 in rewritten_vs:
                        rewritten_cond.append({op:r1})
                return rewritten_cond
            else:
                if isinstance(cond[op], dict):
                    return rewritten_cond
                lhs, rhs = cond[op][0], cond[op][1]
                # nested query
                if isinstance(rhs, dict) and ('select' in rhs or 'select_distinct' in rhs):
                    rewritten_rhs = self.apply(rhs)
                    for r1 in rewritten_rhs:
                        rewritten_cond.append({op:[copy.deepcopy(lhs), r1]})
                return rewritten_cond


        # WHERE, HAVING
        for k in ["where", "having"]:
            tmp_rewritten_qs = []
            for rq in rewritten_qs:
                if k not in rq:
                    continue
                rewritten_conds = rewrite_cond(rq[k])
                for c in rewritten_conds:
                    rq =  copy.deepcopy(rq)
                    rewritten_q = Rule.replace_keyword_nested(rq, k, c)
                    tmp_rewritten_qs.append(rewritten_q)
                    if len(rewritten_qs) + len(tmp_rewritten_qs) > REWRITE_LIMIT:
                            rewritten_qs += tmp_rewritten_qs
                            return rewritten_qs[1:]

            rewritten_qs += tmp_rewritten_qs
            if len(rewritten_qs) > REWRITE_LIMIT:
                return rewritten_qs[1:]
        
        return rewritten_qs[1:]


    # rewrite subquery, different rules behavior differently
    def apply_single(self, q):
        raise NotImplementedError("Sub class must override apply_single")


class RemoveDistinct(Rule):
    def __init__(self, cs) -> None:
        super().__init__(cs)
        self.name = "RemoveDistinct"
        
    def apply_single(self, q):
        if 'select_distinct' in q:
            rewritten_q =  copy.deepcopy(q)
            rewritten_q['select'] = rewritten_q.pop('select_distinct')
            return [rewritten_q]
        return []

class AddLimitOne(Rule):
    def __init__(self, cs) -> None:
        super().__init__(cs)
        self.name = "AddLimitOne"
        
    def apply_single(self, q):
        if 'limit' not in q:
            rewritten_q =  copy.deepcopy(q)
            rewritten_q['limit'] = 1
            return [rewritten_q]
        return []

class ReplaceOuterJoin(Rule):
    def __init__(self, cs) -> None:
        super().__init__(cs)
        self.name = "ReplaceOuterJoin"
    
    def apply_single(self, q):
        if not 'from' in q:
            return []

        from_clause = q['from']
        rewritten_queries = []
        for i, token in enumerate(from_clause):
            if isinstance(token, dict):
                key = list(token.keys())[0]
                if key == 'outer join' or key == 'left outer join' or key == 'left join':
                    rq = copy.deepcopy(q)
                    join = rq['from'][i].pop(key)
                    rq['from'][i]['inner join'] = join
                    rewritten_queries.append(rq)
        return rewritten_queries

class RemoveJoin(Rule):
    def __init__(self, cs) -> None:
        super().__init__(cs)
        self.name = "RemoveJoin"
        
    def apply_single(self, q):
        if not 'from' in q:
            return []
        
        # TODO: handle outer join
        from_clause = q['from']
        inner_joins = []
        for token in from_clause:
            if isinstance(token, dict) and 'inner join' in token.keys():
                inner_joins.append(token['inner join'])
            elif isinstance(token, str):
                pass
            else:
                # Does not handle left outer join for now
                print('[Error] unsupport data type in from clause %s' % token)
                return []

        if len(inner_joins) == 0:
            return []

        def drop(tables):
            if len(tables) == 0:
                return [[]]

            last = tables[-1]
            combs = drop(tables[:-1])
            combs_with_last = []
            for c in combs:
                combs_with_last.append(c + [last])
            combs += combs_with_last
            return combs

        def rewrite_from(drop_tables, from_clause):
            rewritten_from_clause = []
            for token in from_clause:
                if isinstance(token, dict) and "inner join" in token:
                    table = token["inner join"]
                    if not table in drop_tables:
                        rewritten_from_clause.append(token)
                else:
                    rewritten_from_clause.append(token)
            return rewritten_from_clause

        def flatten(ll):
            return [item for sublist in ll for item in sublist]

        def remove_table_predicate(drop_tables, clause):
            # handle where False clause
            if not isinstance(clause, dict):
                return clause
            
            op = list(clause.keys())[0]
            if op == "and" or op == "or":
                clause_list = clause[op]
                items = [remove_table_predicate(drop_tables, i) for i in clause_list]
                items = [i for i in items if i is not None]
                if len(items) == 0:
                    return None
                    # only one element is left, so we do not need and/or any more
                elif len(items) == 1:
                    return items[0]
                    # otherwise, we create a new dic with old op and existing rewrites
                else:
                    return {op: items}
            else:
                values = [s for s in flatten(clause.values()) if isinstance(s, str)]
                for v in values:
                    table = v.split('.')[0]
                    if table in drop_tables:
                        return None
                return clause

        # TODO: optmization: only drop joins with foreign key constraints
        drop_tables_candidates = drop(inner_joins)[1:]
    
        rewritten_qs = []
        for drop_tables in drop_tables_candidates:
            rq = copy.deepcopy(q)
            rewritten_from = rewrite_from(drop_tables, rq['from'])
            rq["from"] = rewritten_from
            if 'where' in rq:
                rewritten_pred = remove_table_predicate(drop_tables, rq['where'])
                if rewritten_pred is None:
                    del rq['where']
                else:
                    rq["where"] = rewritten_pred
            rewritten_qs.append(rq)
        return rewritten_qs

class UnionToUnionAll(Rule):
    def __init__(self, cs) -> None:
        super().__init__(cs)
        self.name = "UnionToUnionAll"
        
    def apply_single(self, q):
        if 'union' in q:
            rewritten_q =  copy.deepcopy(q)
            rewritten_q['union all'] = rewritten_q.pop('union')
            return [rewritten_q]
        return []

class RewriteNullPredicate(Rule):
    def __init__(self, cs) -> None:
        super().__init__(cs)
        self.name = "RewriteNullPredicate"
    
    def apply_single(self, q):
        if 'where' not in q:
            return []
              
        # return: rewrite_result, can_rewrite
        def rewrite_where(clause):
            if not isinstance(clause, dict):
                return clause, False
            op = list(clause.keys())[0]
            if op == "and" or op == "or":
                clause_list = clause[op]
                rewritten_items = []
                can_rewrite = False
                for item in clause_list:
                    r_item, r_can_rewrite = rewrite_where(item)
                    can_rewrite = r_can_rewrite or can_rewrite
                    rewritten_items.append(r_item)
                return {op : rewritten_items}, can_rewrite
            elif op == "missing":
                field = clause[op]
                if not isinstance(field, str):
                    return clause, False
                field_tokens = field.split(".") 
                if len(field_tokens) > 1:
                    table, field = field_tokens[0], field_tokens[1]
                else:
                    table, field = None, field_tokens[0]
                if (table is None and self.constraint.field == field) or \
                        (self.constraint.field == field and self.constraint.table == table):
                    return False, True
                return clause, False
            elif op == "exists":
                field = clause[op]
                if not isinstance(field, str):
                    return clause, False
                field_tokens = field.split(".") 
                if len(field_tokens) > 1:
                    table, field = field_tokens[0], field_tokens[1]
                else:
                    table, field = None, field_tokens[0] 
 
                if (table is None and self.constraint.field == field) or \
                        (self.constraint.field == field and self.constraint.table == table): 
                    return True, True  
                return clause, False
            else: # base case, does not contain and/or and does not have constraint
                return clause, False
         

        rq = copy.deepcopy(q)
        where_clause = rq.pop('where', None)
        rewrite_where_clause, can_rewrite = rewrite_where(where_clause)
        if can_rewrite:
            rq['where'] = rewrite_where_clause
            return [rq]
        return []

class RemovePredicate(Rule):
    def __init__(self, cs) -> None:
        super().__init__(cs)
        self.name = "RemovePredicate"
        
    def apply_single(self, q):
        if 'where' not in q:
            return []
        
        def rewrite_where(clause):
            op = list(clause.keys())[0]
            if op == "and" or op == "or":
                clause_list = clause[op]
                rewritten_items = []
                for item in clause_list:
                    rewritten_items.append(rewrite_where(item))
                # enumerate all possible combinations
                # example:
                # input: rewritten_items([[None, a>0], [None, b>0]])
                # output: [[None, None], [None, b>0], [a>0, None], [a>0, b>0]]
                combs = Rule.comb(rewritten_items)
                def remove_none(l):
                    return [i for i in l if i is not None]
                
                # removing None
                # input: [[None, None], [None, b>0], [a>0, None], [a>0, b>0]]
                # output: [[], [b>0], [a>0], [a>0, b>0]]
                items = [remove_none(i) for i in combs]
                return_wheres = []
                for i in items:
                    # [] --> the clause is dropped completely
                    if len(i) == 0:
                        return_wheres.append(None)
                    # only one element is left, so we do not need and/or any more
                    elif len(i) == 1:
                        return_wheres.append(i[0])
                    # otherwise, we create a new dic with old op and existing rewrites
                    else:
                        return_wheres.append({op:i})
                return return_wheres
            elif self.constraint.field in clause[op] \
                or any(['.' + self.constraint.field in col if isinstance(col, str) else False for col in clause[op]]): # base case, does not contain and/or and has constraint
                  # includes lenient table dot column handling
                  # None means drop this clause
                return  [None, clause]
            else: # base case, does not contain and/or and does not have constraint
                return [clause]
                  
        rq = copy.deepcopy(q)
        where_clause = rq.pop('where', None)
        rewritten_qs = []
        for where in rewrite_where(where_clause)[:-1]:
            rq = copy.deepcopy(q)
            if where is None:
                del rq['where']
            else:
                rq['where'] = where
            rewritten_qs.append(rq)
        return rewritten_qs

class AddPredicate(Rule):
    def __init__(self, cs) -> None:
        super().__init__(cs)
        self.name = "AddPredicate"
        
    def apply_single(self, q):
        constraint_tokens = set([])
        skip_tokens = set([])

        def translate_rhs(t):
            if isinstance(t, int) or isinstance(t, float) or isinstance(t, bool):
                return t, type(t)
            elif isinstance(t, str):
                t = z3.Real(t)
                return t, float # TODO: assume float for variables
            # elif isinstance(t, dict):
            #     return t['literal'], type(t['literal'])
            else:
                print("[Warning] Unknown rhs %s of type %s" % (t, type(t)))
                return None, None

        def translate_lhs(t, _type):
            if _type is None or t is None:
                return None
            if isinstance(t, str) and '.' in t:
                t = t.split('.')[-1]
            if _type == int:
                ret = z3.Int(t)
                return ret
            elif _type == float:
                ret = z3.Real(t)
                return ret
            elif _type == bool:
                ret = z3.Bool(t)
                return ret
            # elif _type == str:
            #     return t
            else:
                print("[Warning] Unknown lhs %s of type %s" % (t, type(t)))
                return None

        all_ops = []
        def extract_binops(q):
            predicate_tokens_map = {}
            def extract_cond(cond):
                key = list(cond.keys())
                assert(len(key) == 1)
                key = key[0]
                # TODO: does not handle exist for now
                if key == "exists":
                    return None
                lhs, rhs = cond[key][0], cond[key][1]
                if key == "and" :
                    elhs, erhs = extract_cond(lhs), extract_cond(rhs)
                    if elhs is None or erhs is None:
                        return None
                    return z3.And(elhs, erhs)
                elif key == "or":
                    elhs, erhs = extract_cond(lhs), extract_cond(rhs)
                    if elhs is None or erhs is None:
                        return None
                    return z3.Or(elhs, erhs)
                elif key in ["gt", "eq", "lt", "gte", "lte"]:
                    rhs, _type = translate_rhs(rhs)
                    lhs = translate_lhs(lhs, _type)
                    
                    if lhs is None or rhs is None:
                        return None
                    
                    if lhs not in predicate_tokens_map:
                        predicate_tokens_map[lhs] = []
                    if rhs not in predicate_tokens_map:
                        predicate_tokens_map[rhs] = []
                    predicate_tokens_map[lhs].append(rhs)
                    predicate_tokens_map[rhs].append(lhs)
                    if key == "gt":
                        all_ops.append(lhs > rhs)
                        all_ops.append(rhs < lhs)
                        return lhs > rhs
                    elif key == "gte":
                        all_ops.append(lhs >= rhs)
                        all_ops.append(rhs <= lhs)
                        return lhs >= rhs
                    elif key == "eq":
                        # only enumerate eq when there both lhs and rhs are variables
                        if type(lhs) in [z3.z3.ArithRef, z3.z3.BoolRef] and type(rhs) in [z3.z3.ArithRef, z3.z3.BoolRef]:
                            pass
                        else:
                            skip_tokens.add(lhs)
                        all_ops.append(lhs == rhs)
                        all_ops.append(rhs == lhs)
                        return lhs == rhs
                    elif key == "lt":
                        all_ops.append(lhs < rhs)
                        all_ops.append(rhs > lhs)
                        return lhs < rhs
                    elif key == "lte":
                        all_ops.append(lhs <= rhs)
                        all_ops.append(rhs >= lhs)
                        return lhs <= rhs
                    else:
                        print("[Error] Unknown key %s" % key)
                        exit(0)

            conditions = []
            if 'where' in q:
                conditions.append(extract_cond(q['where']))
            if 'from' in q and isinstance(q['from'], list) and 'inner join' in q['from'][1]:
                conditions.append(extract_cond(q['from'][1]['on']))
            return conditions, predicate_tokens_map 

        def extract_constraints():
            constraint_tokens = set([])
            conditions = []
            c = self.constraint
            if isinstance(c, NumericalConstraint):
                tmp = z3.Real(c.field)
                constraint_tokens.add(tmp)
                if c.min is not None and c.max is not None:
                    conditions.append(z3.And(tmp >= c.min, tmp <= c.max))
                    constraint_tokens.add(c.min)
                    constraint_tokens.add(c.max)
                    all_ops.append(tmp >= c.min)
                    all_ops.append(tmp <= c.max)
                elif c.min is not None:
                    conditions.append(tmp >= c.min)
                    constraint_tokens.add(c.min)
                    all_ops.append(tmp >= c.min)
                elif c.max is not None:
                    conditions.append(tmp <= c.max)
                    constraint_tokens.add(c.max)
                    all_ops.append(tmp <= c.max)
            return conditions, list(constraint_tokens)

        def deduct(binops, constraint_tokens, candidate_tokens):
            candidates = []
            tokens = list(set(constraint_tokens + candidate_tokens))
            for lhs in set(tokens):
                for rhs in set(tokens):
                    if lhs in skip_tokens or rhs in skip_tokens:
                        continue
                    if lhs in constraint_tokens and rhs in constraint_tokens:
                        continue
                    elif isinstance(lhs, z3.z3.BoolRef) and isinstance(rhs, bool):
                        candidates.append(lhs == rhs)
                        candidates.append(lhs != rhs)
                    elif (isinstance(lhs, z3.z3.ArithRef) and isinstance(rhs, z3.z3.ArithRef) and (lhs is not rhs)) \
                        or (isinstance(lhs, z3.z3.ArithRef) and (type(rhs) in [int, float])) \
                        or ((type(lhs) in [int, float]) and isinstance(rhs, z3.z3.ArithRef)):
                        candidates.append(lhs > rhs)
                        candidates.append(lhs >= rhs) # does not enumerate >= for now
                        candidates.append(lhs == rhs)
                    else:
                        continue
            cond = None
            for binop in binops:
                if cond is None:
                    cond = binop
                else:
                    cond = z3.And(cond, binop)

            variables = [x for x in set(tokens) if isinstance(x, z3.z3.ArithRef) or isinstance(x, z3.z3.BoolRef)]
            
            validate_candidates = []
            for candidate in candidates:
                s = z3.Solver()
                s.add(z3.ForAll(variables, z3.Implies(cond, candidate)))
                if s.check() == z3.sat:
                    # print("====Imply====")
                    # print("skip tokens", skip_tokens)
                    # print("enumerate tokens", tokens)
                    # print("variables: ", variables)
                    # print("cond:", cond)
                    # print("result:", candidate)
                    validate_candidates.append(candidate)
            return validate_candidates

        # extract constraints
        # and translate into z3 format
        constraint_ops, constraint_tokens = extract_constraints()
        if len(constraint_ops) == 0:
            return []
        # print("Constraint tokens", constraint_tokens)
        # extract binary operations from where and join conditions
        # the output of binary operations is in z3 format
        binops, predicate_tokens_map = extract_binops(q)
        if len(predicate_tokens_map) == 0:
            return []

        binops += constraint_ops

        binops = [op for op in binops if op is not None]
        
        # only deduct tokens that might have constraints
        candidate_tokens = constraint_tokens
        before_size = -1 
        while len(candidate_tokens) != before_size:
            before_size = len(candidate_tokens)
            new_candidate_tokens = []
            for t in candidate_tokens:
                if t in predicate_tokens_map:
                    new_candidate_tokens += predicate_tokens_map[t] 
            candidate_tokens = list(set(new_candidate_tokens + candidate_tokens))
        # print("candidate tokens", candidate_tokens)

        if len(candidate_tokens) == 0:
            return []
       
        # candidate_tokens += list(constraint_tokens)
        candidate_predicates = deduct(binops, constraint_tokens, candidate_tokens)

        # if we already know a < 100, candidate a < 200 is redundant and should be removed
        def validate_predicates(candidates, all_ops):
            def is_redundant(can, all_ops):
                # assume candidate is in the form : variable op variable/value
                lhs, rhs = can.children()[0], can.children()[1]
                if type(rhs) not in [z3.z3.RatNumRef, z3.z3.IntNumRef]:
                    return False
                relate_ops = set([o for o in all_ops if str(o.children()[0]) == str(lhs)])
                if str(can.decl()) in ["<", "<="]:
                    relate_ops = [o for o in relate_ops if str(o.decl()) in ["<", "<="] and \
                                    type(o.children()[1]) in [z3.z3.RatNumRef, z3.z3.IntNumRef]]
                    for o in relate_ops:
                        if float(str(rhs)) >= float(str(o.children()[1])):
                            return True
                elif str(can.decl()) in [">", ">="]:
                    relate_ops = [o for o in relate_ops if str(o.decl()) in [">", ">="] and \
                                    type(o.children()[1]) in [z3.z3.RatNumRef, z3.z3.IntNumRef]]
                    for o in relate_ops:
                        if float(str(rhs)) <= float(str(o.children()[1])):
                            return True
                    
                return False
            
            redundant_can = set([])
            for can in candidates:
                if is_redundant(can, all_ops):
                    redundant_can.add(can)
            return candidates - redundant_can
        
        candidate_predicates = validate_predicates(set(candidate_predicates) - set(binops) - set(all_ops), all_ops)
        candidate_predicates = set(candidate_predicates) - set(binops) - set(all_ops)
        
        if len(candidate_predicates) > 0:
            print("Cond", binops)
            print("Candidate", candidate_predicates)
            print()

        rewritten_qs = []
        def z3op_to_json(binop):
            def z3_to_type(token):
                if isinstance(token, z3.z3.RatNumRef) or isinstance(token, z3.z3.IntNumRef):
                    if token.is_int():
                        return int(token.as_long())
                    elif token.is_real():
                        return float(token.as_decimal(3))
                else:
                    return str(token)
                
            op_map = {
                '>' : 'gt',
                '==' : 'eq',
                '<' : 'lt',
                '>=' : 'gte',
                '<=' : 'lte',
                'Distinct' : 'neq'
            }
            ret = {op_map[str(binop.decl())]: [z3_to_type(c) for c in binop.children()]}
            return ret

        # add candidate predicates to q
        for candidate in candidate_predicates:
            rq = copy.deepcopy(q)
            org_pred = rq['where']
            rq['where'] = {'and': [org_pred, z3op_to_json(candidate)]}
            rewritten_qs.append(rq)
        return rewritten_qs
