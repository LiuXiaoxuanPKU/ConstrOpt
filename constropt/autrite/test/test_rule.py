import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from constraint import NumericalConstraint, PresenceConstraint
from rule import AddLimitOne, RemoveDistinct, AddPredicate, RemovePredicate, RewriteNullPredicate, UnionToUnionAll, RemoveJoin
from mo_sql_parsing import parse, format

def test_q_obj(q_obj, q_str):
    q_str = format(parse(q_str))
    if format(q_obj) != q_str:
        print("Expect ", q_str)
        print("Get ", format(q_obj))
    assert(format(q_obj) == q_str)

def test_add_limit_one_select_from():
    print("===============Add Limit One=================")
    q_before_str = "select * from R"
    q_after_str = "select * from R limit 1"
    q_before = parse(q_before_str)
    q_afters = AddLimitOne(None).apply(q_before)
    assert(len(q_afters) == 1)
    q_after = q_afters[0]
    test_q_obj(q_after, q_after_str)

    q_before_str = "select * from (select * from R where id = 2) where a = 1"
    q_before = parse(q_before_str)
    q_afters = AddLimitOne(None).apply(q_before)
    assert(len(q_afters) == 3)
    print("Before: ", format(q_before))
    print("After: ")
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select (select * from R where id = 2) from R where a = 1"
    q_before = parse(q_before_str)
    q_afters = AddLimitOne(None).apply(q_before)
    assert(len(q_afters) == 3)
    print("Before: ", format(q_before))
    print("After: ")
    for q in q_afters:
        print(format(q))
    
    print("--------------")
    q_before_str = "select (select * from R where id = 2) from (select * from R where id = 3) where a = 1"
    q_before = parse(q_before_str)
    q_afters = AddLimitOne(None).apply(q_before)
    assert(len(q_afters) == 7)
    print("Before: ", format(q_before))
    print("After: ")
    for q in q_afters:
        print(format(q))

def test_add_limit_one_where_having():
    print("--------------")
    q_before_str = "select * from R1 where a in (select a from R2) and a > 1"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddLimitOne(None).apply(q_before)
    for q in q_afters:
        print(format(q))
    assert(len(q_afters) == 3)
    
    print("--------------")
    q_before_str = "select * from R1 where a in (select a from R2) and b in (select b from R3)"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddLimitOne(None).apply(q_before)
    assert(len(q_afters) == 7)
    for q in q_afters:
        print(format(q))

    print("---------------")
    q_before_str = "select * from R1 group by b having c > (select c from R2)"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddLimitOne(None).apply(q_before)
    assert(len(q_afters) == 3)
    for q in q_afters:
        print(format(q))


def test_remove_distinct_select_from():
    print("===============Remove Distinct=================")
    q_before_str = "select distinct c from (select distinct(*) from R) where a = 1"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = RemoveDistinct(None).apply(q_before)
    assert(len(q_afters) == 3)
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select distinct(select distinct * from R1) from (select distinct(*) from R2) where a = 1"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = RemoveDistinct(None).apply(q_before)
    assert(len(q_afters) == 7)
    for q in q_afters:
        print(format(q))

def test_add_limit_one_exist():
    pass

def test_add_predicate_simple():
    print("===============Add Predicate=================")
    q_before_str = "select * from R where a >= b"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = AddPredicate(c).apply(q_before)
    # assert(len(q_afters) == 1)
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select * from R where a > b and a > c"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = AddPredicate(c).apply(q_before)
    # assert(len(q_afters) == 1)
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select * from R where a > b or a < c"
    # select * from R where (a > b and b < 100) or a < c
    # select * from R where a > b or (a < c and c > 0)
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddPredicate(c).apply(q_before)
    # assert(len(q_afters) == 1)
    for q in q_afters:
        print(format(q))
        
    print("--------------")
    q_before_str = "select * from R where a = b"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddPredicate(c).apply(q_before)
    # assert(len(q_afters) == 1)
    for q in q_afters:
        print(format(q))

def test_add_predicate_validate():
    print("===============Add Predicate Validate, remove redundant predicates=================")
    q_before_str = "select * from R where b = 147 and a < b"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = AddPredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))

def test_add_predicate_transitivity():
    print("===============Add Predicate Transitivity, only enumerate tokens that might have constraints =================")
    q_before_str = "select * from R where a = b and b = c and d < 100"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = AddPredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))
        
def test_add_predicate_join():
    print("===============Add Predicate Join =================")
    q_before_str = "select * from R1 INNER JOIN R2 on R1.a = R2.b where R1.a > 1"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R1", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = AddPredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))

def test_remove_predicate_simple():
    print("===============Remove Predicate=================")
    q_before_str = "select * from R where a > b"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select * from R where a > b or a > c"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select * from R where a > b or a < c and a > d"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select * from R where a > b and a < c and a > d"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))
    
    print("--------------")
    q_before_str = "select * from R where a > b or b > c and c > d or d > e and e > f"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "b", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters))

    print("--------------")
    q_before_str = "select * from R where a > b or b > c and c > d or d > e and e > f or f > g"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "f", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters))

    print("--------------")
    q_before_str = "select * from R where a > b and b > c or c > d and d > e or e > f"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "d", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters))

    print("--------------")
    q_before_str = "select * from R where a > c and (b > c or c > d) and c > e or e > f"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "c", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters))

    print("--------------")
    q_before_str = "SELECT 1 AS one FROM members WHERE members.user_id IS NULL AND members.project_id = $1 LIMIT $2"
    q_before = parse(q_before_str)
    c = NumericalConstraint("members", "user_id", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters)) #1

    print("--------------")
    q_before_str = "SELECT 1 AS one FROM members WHERE members.user_id IS NULL AND members.project_id = $1 LIMIT $2"
    q_before = parse(q_before_str)
    c = NumericalConstraint("members", "project_id", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters)) #1

    print("--------------")
    q_before_str = "SELECT members.* FROM members INNER JOIN projects ON projects.id = members.project_id WHERE members.user_id = $1 AND projects.status != $2 AND members.project_id IS NULL ORDER BY members.id ASC LIMIT $3"
    q_before = parse(q_before_str)
    c = NumericalConstraint("members", "project_id", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters)) #1

    print("--------------")
    q_before_str = "SELECT members.* FROM members INNER JOIN projects ON projects.id = members.project_id WHERE members.project_id = $1 AND members.project_id != $2 AND members.project_id IS NULL ORDER BY members.id ASC LIMIT $3"
    q_before = parse(q_before_str)
    c = NumericalConstraint("members", "project_id", False, 0, 100)
    print("Before: ", format(q_before))
    print("Constraint: ", str(c))
    print("After: ")
    q_afters = RemovePredicate(c).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters)) #7

def test_union_all_simple():
    q_before_str = "SELECT City FROM Customers UNION SELECT City FROM Suppliers ORDER BY City;"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = UnionToUnionAll(None).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters))

    print("--------------")
    q_before_str = "SELECT City FROM Customers UNION SELECT City FROM Suppliers UNION SELECT City FROM Shipments ORDER BY City;"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = UnionToUnionAll(None).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters))


def test_remove_join():
    q_before_str = "SELECT roles.* FROM roles INNER JOIN queries_roles ON roles.id = queries_roles.role_id WHERE queries_roles.query_id = 1"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = RemoveJoin(None).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters))

    print("--------------")
    q_before_str = "select * from R1 INNER JOIN R2 ON R1.id = R2.r1_id INNER JOIN R3 ON R1.id = R3.ri_id WHERE R1.id = 1 and R2.id = 2 and R3.id = 3"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = RemoveJoin(None).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters))

def test_removenull_predicate():
    q_before_str = "select * from R where a is NULL"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = RewriteNullPredicate(PresenceConstraint("R", "a")).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters))
    
    q_before_str = "select * from R where b = 0 and a is not NULL"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = RewriteNullPredicate(PresenceConstraint("R", "a")).apply(q_before)
    for q in q_afters:
        print(format(q))
    print(len(q_afters))
    
if __name__ == "__main__":
    test_add_limit_one_select_from()
    test_remove_distinct_select_from()
    test_add_limit_one_where_having()
    #test_add_predicate_simple()
    #test_add_predicate_validate()
    #test_add_predicate_join()
    #test_add_predicate_transitivity()
    #test_remove_predicate_simple()
    # test_union_all_simple()
    # test_remove_join()
    # test_removenull_predicate()