import sys
import os
from mo_sql_parsing import parse, format
import unittest
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from constraint import FormatConstraint, InclusionConstraint
from extract_rule import ExtractQueryRule

class TestInclusionConstraintQuery(unittest.TestCase):
    
    def test_non_example_naive(self):
        cs = [InclusionConstraint("auth_sources", "fake_column", False, [])]
        q = "SELECT 1 AS one FROM auth_sources LIMIT 1"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 0)

    def test_where_naive(self):
        cs = [InclusionConstraint("attachments", "disk_filename", False, [])]
        q = "SELECT 1 AS one FROM attachments WHERE disk_filename = '060719210727_archive.zip'"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 1)

    def test_where_naive_2(self):
        cs = [InclusionConstraint("roles", "builtin", False, [])]
        q = "SELECT roles.* FROM roles WHERE NOT(builtin = 0)"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 1)

    def test_where_naive_3(self):
        cs = [InclusionConstraint("roles", "anycolumn", False, [])]
        q = "SELECT roles.anycolumn1 FROM roles WHERE NOT(builtin = 0)"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 0)

    def test_where_and(self):
        cs = [InclusionConstraint("attachments", "disk_filename", False, [])]
        q = "SELECT 1 AS one FROM attachments WHERE disk_filename = '060719210727_archive.zip' AND id <> 21 LIMIT 1"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 1)

    def test_select_distinct(self):
        cs = [InclusionConstraint("attachments", "filename", False, [])]
        q = "SELECT DISTINCT attachments.filename AS alias_0, projects.id FROM projects LEFT OUTER JOIN attachments ON attachments.container_id = projects.id AND attachments.container_type = 1 WHERE projects.id = 2 ORDER BY attachments.filename ASC LIMIT 3"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 1)

    def test_join(self):
        cs = [InclusionConstraint("projects", "id", False, [])]
        q = "SELECT DISTINCT attachments.filename AS alias_0, projects.id FROM projects LEFT OUTER JOIN attachments ON attachments.container_id = projects.id AND attachments.container_type = 1 WHERE projects.id = 2 ORDER BY attachments.filename ASC LIMIT 3"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 1)

    def test_on(self):
        cs = [InclusionConstraint("attachments", "container_id", False, [])]
        q = "SELECT DISTINCT attachments.filename AS alias_0, projects.id FROM projects LEFT OUTER JOIN attachments ON attachments.container_id = projects.id AND attachments.container_type = 1 WHERE projects.id = 2 ORDER BY attachments.filename ASC LIMIT 3"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 1)

    def test_order_by(self):
        cs = [InclusionConstraint("attachments", "butterfly", False, [])]
        q = "SELECT DISTINCT attachments.filename AS alias_0, projects.id FROM projects LEFT OUTER JOIN attachments ON attachments.container_id = projects.id AND attachments.container_type = 1 WHERE projects.id = 2 ORDER BY attachments.butterfly ASC LIMIT 3"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 1)

    def test_subquery(self):
        cs = [InclusionConstraint("projects", "id", False, [])]
        q = "SELECT 1 AS one FROM enabled_modules WHERE enabled_modules.project_id IN (SELECT projects.id FROM projects WHERE projects.status <> 9 AND projects.is_public = True AND projects.id NOT IN (SELECT project_id FROM members WHERE user_id IN (74, 12))) AND enabled_modules.name = 1 LIMIT 2"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 1)

    def test_alias_in_subquery(self):
        cs = []
        q = "SELECT news.* FROM news INNER JOIN projects ON projects.id = news.project_id WHERE news.created_on BETWEEN '2022-02-04' AND '2022-02-14' AND news.author_id = 2 AND projects.status <> 9 AND (SELECT 1 AS one FROM enabled_modules AS em WHERE em.project_id = projects.id AND em.name = 'news') IS NOT NULL"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 1)


class TestFormatConstraintQuery(unittest.TestCase):
    def test_non_example_naive(self):
        cs = [FormatConstraint("auth_sources", "fake_column", False, "a-zA-Z")]
        q = "SELECT 1 AS one FROM auth_sources LIMIT 1"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 0) 
    
    def test_where_naive(self):
        cs = [FormatConstraint("attachments", "disk_filename", False, "a-zA-Z")]
        q = "SELECT 1 AS one FROM attachments WHERE disk_filename = '060719210727_archive.zip'"
        q = parse(q)
        extracted = ExtractQueryRule(cs).apply(q)
        self.assertEqual(len(extracted), 1) 

if __name__ == "__main__":
    unittest.main()
    