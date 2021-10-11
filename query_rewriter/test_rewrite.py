from constraint import FormatConstraint, InclusionConstraint, LengthConstraint
import unittest
import rewrite
from constraint import UniqueConstraint
from mo_sql_parsing import parse, format


class TestRewrite(unittest.TestCase):
    def __init__(self, methodName: str = ...) -> None:
        super().__init__(methodName=methodName)
        self.unique_constraints = [UniqueConstraint("users", "name")]
        self.inclusion_constraints = [
            InclusionConstraint("users", "gender", ["F", "M"])]
        self.length_constraints = [LengthConstraint("users", "name", 0, 30)]
        self.format_constraints = [
            FormatConstraint("users", "name", '[A-Za-z]')]

    def test_find_field(self):
        sql1 = "SELECT * from users where name = $1 and gender = $2 and project_id = $3"
        predicate1 = parse(sql1)['where']
        self.assertTrue(rewrite.find_field_in_predicate("name", predicate1))
        self.assertTrue(rewrite.find_field_in_predicate(
            "project_id", predicate1))
        self.assertFalse(rewrite.find_field_in_predicate("user", predicate1))
        sql2 = "SELECT * from users where name = $1 and gender = $2 or project_id = $3"
        predicate2 = parse(sql2)['where']
        self.assertTrue(rewrite.find_field_in_predicate(
            "project_id", predicate2))
        self.assertFalse(rewrite.find_field_in_predicate("id", predicate2))
        sql3 = "SELECT * from users INNER JOIN projects where users.name = $1 and users.gender = $2 or users.project_id = $3 or projects.id = $4"
        predicate3 = parse(sql3)['where']
        self.assertTrue(rewrite.find_field_in_predicate(
            "users.project_id", predicate3))
        self.assertFalse(rewrite.find_field_in_predicate(
            "project_id", predicate3))

    def test_add_limit_one_single_predicate(self):
        sql1 = "SELECT * FROM users where name = $1"
        can_rewrite1, rewrite_sql1 = rewrite.add_limit_one(
            parse(sql1), self.unique_constraints)
        self.assertTrue(can_rewrite1)
        self.assertTrue('limit' in rewrite_sql1)
        self.assertEqual(format(parse(sql1 + " LIMIT 1")),
                         format(rewrite_sql1))

        sql2 = "SELECT * FROM users where gender = $1"
        can_rewrite2, rewrite_sql2 = rewrite.add_limit_one(
            parse(sql2), self.unique_constraints)
        self.assertFalse(can_rewrite2)
        self.assertIsNone(rewrite_sql2)

    def test_add_limit_one_multiple_predicates(self):
        sql1 = "SELECT * from users where name = $1 and gender = $2"
        can_rewrite1, rewrite_sql1 = rewrite.add_limit_one(
            parse(sql1), self.unique_constraints)
        self.assertTrue(can_rewrite1)
        self.assertTrue('limit' in rewrite_sql1)
        self.assertEqual(format(parse(sql1 + " LIMIT 1")),
                         format(rewrite_sql1))

        sql2 = "SELECT * from users where name = $1 or gender = $2"
        can_rewrite2, rewrite_sql2 = rewrite.add_limit_one(
            parse(sql2), self.unique_constraints)
        self.assertFalse(can_rewrite2)
        self.assertIsNone(rewrite_sql2)

        sql3 = "SELECT * from users where age = 15 and name = $1 and gender = $2"
        can_rewrite3, rewrite_sql3 = rewrite.add_limit_one(
            parse(sql3), self.unique_constraints)
        self.assertTrue(can_rewrite3)
        self.assertTrue('limit' in rewrite_sql3)
        self.assertEqual(format(parse(sql3 + " LIMIT 1")),
                         format(rewrite_sql3))

    def test_add_limit_one_join(self):
        pass

    def test_str2int(self):
        sql1 = "SELECT * FROM users where gender = 'F'"
        can_rewrite1, rewrite_fields1 = rewrite.str2int(
            parse(sql1), self.inclusion_constraints)
        self.assertTrue(can_rewrite1)
        self.assertEqual(rewrite_fields1, ["gender"])
        sql2 = "SELECT * FROM users INNER JOIN projects\
             WHERE users.gender = 'F' and projects.id = 1"
        can_rewrite2, rewrite_fields2 = rewrite.str2int(
            parse(sql2), self.inclusion_constraints)
        self.assertTrue(can_rewrite2)
        self.assertEqual(rewrite_fields2, ["users.gender"])
        sql3 = "SELECT gender FROM users where id > 0"
        can_rewrite3, rewrite_fields3 = rewrite.str2int(
            parse(sql3), self.inclusion_constraints)
        self.assertFalse(can_rewrite3)
        self.assertEqual(len(rewrite_fields3), 0)

    def test_strlen_precheck(self):
        sql1 = "SELECT * FROM users where name = 'bob'"
        can_rewrite1, rewrite_fields1 = rewrite.strlen_precheck(
            parse(sql1), self.length_constraints)
        self.assertTrue(can_rewrite1)
        self.assertEqual(rewrite_fields1, ["name"])
        sql2 = "SELECT * FROM users where age = 10"
        can_rewrite2, rewrite_fields2 = rewrite.strlen_precheck(
            parse(sql2), self.length_constraints)
        self.assertFalse(can_rewrite2)
        self.assertEqual(len(rewrite_fields2), 0)

    def test_strformat_precheck(self):
        sql1 = "SELECT * FROM users where name = 'bob'"
        can_rewrite1, rewrite_fields1 = rewrite.strformat_precheck(
            parse(sql1), self.format_constraints)
        self.assertTrue(can_rewrite1)
        self.assertEqual(rewrite_fields1, ["name"])
        sql2 = "SELECT * FROM users where age = 10"
        can_rewrite2, rewrite_fields2 = rewrite.strformat_precheck(
            parse(sql2), self.format_constraints)
        self.assertFalse(can_rewrite2)
        self.assertEqual(len(rewrite_fields2), 0)

    def test_remove_distinct(self):
        # base case: one table, select column has unique constraint
        sql1 = "SELECT distinct(name) from users where name = $1"
        can_rewrite1, rewrite_sql1 = rewrite.remove_distinct(parse(sql1), self.unique_constraints)
        self.assertTrue(can_rewrite1)
        self.assertTrue('distinct' not in rewrite_sql1)

        # inner join case
        sql2 = "SELECT distinct(project.id) from users INNER JOIN projects where projects.id = users.project_id and projects.id = 1"
        can_rewrite2, rewrite_sql2 = rewrite.remove_distinct(parse(sql2), self.unique_constraints)
        self.assertTrue(can_rewrite2)
        self.assertTrue('distinct' not in rewrite_sql2)

        # left outer join case
        sql3 = "SELECT * from users LEFT JOIN projects where projects.id = users.project_id and projects.id = 1"

if __name__ == '__main__':
    unittest.main()
