from constraint import LengthConstraint
from constraint import UniqueConstraint, InclusionConstraint, FormatConstraint
from mo_sql_parsing import parse, format
import functools
import json


def find_constraint(constraints, table, field, constraint_type):
    re = list(filter(lambda x: isinstance(x, constraint_type)
              and x.table == table and x.field == field, constraints))
    return len(list(re)) > 0


def get_constraint_fields(constraints, constraint_type):
    selected_constraints = filter(
        lambda x: isinstance(x, constraint_type), constraints)
    return list(map(lambda x: x.table + "." + x.field, selected_constraints))


def find_field_in_predicate(field, predicate):
    keys = list(predicate.keys())
    assert(len(keys) == 1)
    key = keys[0]
    values = list(predicate[key])

    if isinstance(values[0], str):
        return field in values
    return functools.reduce(lambda acc, item: acc or find_field_in_predicate(field, item), values, False)


def check_query_has_join(q):
    table = q['from']
    return functools.reduce(
        lambda acc, item: acc or ('inner join' in item) or ('left outer join' in item), table, False)


def add_limit_one(q, constraints):
    if 'limit' in q:
        return False, None
    where_clause = q['where']
    keys, values = list(where_clause.keys()), list(where_clause.values())
    has_join = check_query_has_join(q)
    assert(len(keys) == 1)
    key = keys[0]

    def check_predicate_return_one_tuple(key, table, field):
        return key == 'eq' and find_constraint(constraints, table, field, UniqueConstraint)

    # case 1: no join, only has one predicate
    if not has_join and check_predicate_return_one_tuple(key, q['from'], values[0][0]):
        rewrite_q = q.copy()
        rewrite_q['limit'] = 1
        return True, rewrite_q
    # case 2: no join, predicates are connected by 'and'
    elif not has_join and key in ["and"]:
        # as long as all predicates are connected by 'and'
        # and there exists one predicate that returns only one tuple
        predicates = where_clause['and']
        return_one = False
        table = q['from']
        for pred in predicates:
            return_one = return_one or check_predicate_return_one_tuple(
                list(pred.keys())[0], table, list(pred.values())[0][0])
        if return_one:
            rewrite_q = q.copy()
            rewrite_q['limit'] = 1
            return True, rewrite_q
    # case 3: inner join, each relation returns no more than 1 tuple
    elif has_join:
        pass

    return False, None

def check_table_contain_constraints(table, constraints, constraint_type):
    """Return True if a certain type constraint appear in table."""
    for constraint in constraints:
        if constraint.table == table and isinstance(constraint, constraint_type):
            return True
    return False

def table_unique_set(table, constraints):
    s = set()
    for constraint in constraints:
        if constraint.table == table and isinstance(constraint, UniqueConstraint):
            s.add(constraint.table + '.' + constraint.field)
            s.add(constraint.field)
    return s

def check_join_conditions(table, u_in1, u_in2):
    success = True
    #potentially fail if there is a join condition
    if 'on' in table:
        #assume uniqueness is only maintained on equality join condition
        if 'eq' not in table['on']:
            success = False
            #check for potential equality conditions within the and
            if 'and' in table['on']:
                for d in table['on']['and']:
                    if 'eq' in d:
                        #check that equality is on two unique columns
                        success = True
                        for col in d['eq']:
                            success &= col in u_in1 or col in u_in2
                        break
        else:
            #check that equality is on two unique columns
            for col in table['on']['eq']:
                success &= col in u_in1 or col in u_in2
    return success

def remove_distinct(q, constraints):
    def contain_distinct(q):
        """return True if sql contain 'distinct' key word."""
        if not isinstance(q['select'], dict) or 'distinct' not in q['select']['value']:
            return False
        return True

    if not contain_distinct(q):
        return False, None
    has_join = check_query_has_join(q)
    tables = q['from']
    projections = q['select']['value']['distinct']
    # base case: no joins, do some weird handling to make this work with the rest of the code
    if not has_join:
        tables = [tables]
    r_in1 = tables[0]
    #get unique set of initial table
    u_in1 = table_unique_set(r_in1, constraints)
    for t in tables[1:]:
        if 'inner join' in t:
            #get table 2 and its unique set
            r_in2 = t['inner join']
            u_in2 = table_unique_set(r_in2, constraints)
            #check fail: u_out is empty set. else, u_out is union of u_in1 and u_in2.
            if check_join_conditions(t, u_in1, u_in2):
                u_in1 = u_in1.union(u_in2)
            else:
                u_in1 = set()
        elif 'left outer join' in t:
            #get table 2 and its unique set
            r_in2 = t['left outer join']
            u_in2 = table_unique_set(r_in2, constraints)
            #check fail: u_out is empty set. else, u_out is u_in1.
            if not check_join_conditions(t, u_in1, u_in2):
                u_in1 = set()
    # lotta cases to handle individually here
    if isinstance(projections, dict):
        if isinstance(projections['value'], list):
            for col in projections['value']:
                if col in u_in1:
                    rewrite_q = q.copy()
                    rewrite_q['select'] = projections['value']
                    return True, rewrite_q
        elif projections['value'] == '*' and u_in1 or projections['value'] in u_in1:
            rewrite_q = q.copy()
            rewrite_q['select'] = projections['value']
            return True, rewrite_q
    elif isinstance(projections, list):
        for d in projections:
            if d['value'] in u_in1:
                rewrite_q = q.copy()
                rewrite_q['select'] = projections
                return True, rewrite_q
    return False, None

def str2int(q, constraints):
    enum_fields = get_constraint_fields(constraints, InclusionConstraint)
    predicate = q['where']
    # if q does not have join, field does not need prefix (table name)
    has_join = check_query_has_join(q)
    if not has_join:
        enum_fields = list(map(lambda x: x.split('.')[1], enum_fields))
    str2_int_fields = functools.reduce(lambda acc, item: acc + [item] if find_field_in_predicate(
        item, predicate) else acc, enum_fields, [])
    can_rewrite = len(str2_int_fields) > 0
    return can_rewrite, str2_int_fields


def strlen_precheck(q, constraints):
    strlen_fields = get_constraint_fields(constraints, LengthConstraint)
    predicate = q['where']
    has_join = check_query_has_join(q)
    if not has_join:
        strlen_fields = list(map(lambda x: x.split('.')[1], strlen_fields))
    len_precheck_fields = functools.reduce(lambda acc, item: acc + [item] if find_field_in_predicate(
        item, predicate) else acc, strlen_fields, [])
    can_rewrite = len(len_precheck_fields) > 0
    return can_rewrite, len_precheck_fields


def strformat_precheck(q, constraints):
    strformat_fields = get_constraint_fields(constraints, FormatConstraint)
    predicate = q['where']
    has_join = check_query_has_join(q)
    if not has_join:
        strformat_fields = list(
            map(lambda x: x.split('.')[1], strformat_fields))
    format_precheck_fields = functools.reduce(lambda acc, item: acc + [item] if find_field_in_predicate(
        item, predicate) else acc, strformat_fields, [])
    can_rewrite = len(format_precheck_fields) > 0
    return can_rewrite, format_precheck_fields


def rewrite(q, constraints):
    can_add_limit_one, rewrite_q = add_limit_one(q, constraints)
    if can_add_limit_one:
        print("Add limit 1 ", format(rewrite_q))
    can_str2int, rewrite_fields = str2int(q, constraints)
    if can_str2int:
        print("String to Int", format(q), rewrite_fields)
    can_strlen_precheck, lencheck_fields = strlen_precheck(q, constraints)
    if can_strlen_precheck:
        print("Length precheck", format(q), lencheck_fields)
    can_strformat_precheck, formatcheck_fields = strformat_precheck(
        q, constraints)
    if can_strformat_precheck:
        print("String format precheck", format(q), formatcheck_fields)
    can_remove_distinct, rewrite_q = remove_distinct(q, constraints)
    if can_remove_distinct:
        print("Remove Distinct", format(rewrite_q))


if __name__ == "__main__":
    filename = "query.sql"
    constraints = [UniqueConstraint("users", "name"), UniqueConstraint("projects", "id"), UniqueConstraint("users", "project")]
    with open(filename, 'r') as f:
        sqls = f.readlines()
    for sql in sqls:
        print(sql.strip())
        sql_obj = parse(sql.strip())
        print(json.dumps(sql_obj, indent=4))
        rewrite(sql_obj, constraints)
