from config import REWRITE_LIMIT, RewriteQuery
from constraint import *
from rule import AddPredicate, RemoveDistinct, AddLimitOne, RemoveJoin, RemovePredicate, RewriteNullPredicate, UnionToUnionAll, ReplaceOuterJoin
from mo_sql_parsing import format
import copy

class Rewriter:
    def __init__(self) -> None:
        self.rules = []

    def set_rules(self, rules):
        self.rules = rules

    def rewrite(self, constraints, q):
        # identify constraints in q
        constraints = Rewriter.get_q_constraints(constraints, q.q_obj)
        if not len(constraints):
            return []
        
        # use constraints to generate potential rules
        rules = self.get_rules(constraints)
        # print("Apply rule", rules)
        
        # order rules, apply slow rules (add predicate, remove predicate) first
        rules.sort()

        rewritten_queries = self.bfs(rules, q)

        return rewritten_queries

    
    # select * from R where a = 1
    # UniqueConstraint(a)
    @staticmethod
    def get_q_constraints(constraints, q):
        def extract_q_field(q):
            # TODO: extract all the fields insteaf of all the tokens
            q_str = format(q)
            tokens = [t.lower().split('.')[-1] for t in q_str.split(' ')]
            return tokens

        def get_field_constraint(field, constraints):
            field_constraints = []
            for c in constraints:
                if c.field == field or (isinstance(c.field, list) and field in c.field):
                    field_constraints.append(c)
            return field_constraints

        # extract fields in q
        fields = extract_q_field(q)
        q_constraints = []
        for field in fields:
            cs = get_field_constraint(field, constraints)
            q_constraints += cs
        
        return list(set(q_constraints))

    def get_rules(self, constraints):
        constraint_rule_map = {
            UniqueConstraint : [RemoveDistinct, AddLimitOne],
            NumericalConstraint : [AddPredicate, RemovePredicate],
            PresenceConstraint : [RewriteNullPredicate, ReplaceOuterJoin, RemoveJoin],
            InclusionConstraint : [], 
            LengthConstraint : [],
            FormatConstraint : [],
            ForeignKeyConstraint : [RemoveJoin]
            }
        rules = []
        for c in constraints:
            rules += [r(c) for r in constraint_rule_map[type(c)]]
        rules = set(rules)
        if self.rules != []:
            return [r for r in rules if type(r) in self.rules]
        else:
            return list(rules) 

    def bfs(self, rules, q):
        rewritten_queries = [q]
        applied_rules = []
        for rule in rules:
            if len(rewritten_queries) > REWRITE_LIMIT:
                break
            applied_rules.append(rule)
            rule_rewritten_qs = []
            for rq in rewritten_queries:
                rule_rewritten_qs += rule.apply(rq.q_obj)
            
            rule_rewritten_q_objs = []
            for q in rule_rewritten_qs:
                rq = RewriteQuery(format(q), q) 
                rq.rewrites = applied_rules
                rule_rewritten_q_objs.append(rq)
            
            if len(rule_rewritten_q_objs) == 0:
                applied_rules.pop()
            rewritten_queries += rule_rewritten_q_objs
    
        return rewritten_queries[1:]




