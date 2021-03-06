import functools
from .constraint import *


def strformat_precheck(self, q, constraints):
    rewrite_type_set = set()
    if 'from' in q:
        rewrite_type_set = self.rewrite_all_subqueries(
            q['from'], constraints, set())
    if 'where' not in q:
        return rewrite_type_set, q
    strformat_fields = self.get_constraint_fields(
        constraints, FormatConstraint)
    predicate = q['where']
    has_join = self.check_query_has_join(q)
    if not has_join:
        strformat_fields = list(
            map(lambda x: x.split('.')[1], strformat_fields))
    format_precheck_fields = functools.reduce(lambda acc, item: acc + [item] if self.find_field_in_predicate(
        item, predicate) else acc, strformat_fields, [])
    if len(format_precheck_fields) > 0:
        rewrite_type_set.add(self.RewriteType.FORMAT_PRECHECK)
    return rewrite_type_set, format_precheck_fields
