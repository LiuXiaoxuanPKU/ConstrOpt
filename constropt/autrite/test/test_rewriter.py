import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from constraint import *
from rewriter import Rewriter
from mo_sql_parsing import parse, format
from loader import Loader
from config import RewriteQuery, get_filename, FileType
import rule

def test_get_constraints():
    constraints = [UniqueConstraint("users", ["id"], False, 'builtin', None), 
                   UniqueConstraint("projects", ["id"], False, 'builtin', None),
                   InclusionConstraint("users", "id", False, [1, 2]), 
                   UniqueConstraint("members", ["name"], False, 'builtin', None),
                    UniqueConstraint("users", ["name"], False, 'builtin', None)]
    q_before_str = "select distinct (*) from users where id \
                        in (select distinct user_id from projects)"
    rewriter = Rewriter()
    q = RewriteQuery(q_before_str, parse(q_before_str))
    constraints = rewriter.get_q_constraints(constraints,q.q_obj)
    assert(len(constraints) == 3)

def test_get_rules():
    constraints = [UniqueConstraint("users", ["id"], False, 'builtin', None),
                   NumericalConstraint("projects", "id", False, 0, 100),
                   InclusionConstraint("users", "id", False, [1, 2])]
    rewriter = Rewriter()
    rules = rewriter.get_rules(constraints)
    assert(len(set(rules)) == 4)

def test_rewrite_helper(constraints, q_str):
    rewriter = Rewriter()
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    print("------------------------Start Rewrite------------------------")
    print("Before:\n", format(parse(q_str)))
    print("After:", len(rewritten_queries))
    # for q in rewritten_queries:
    #     print(format(q))
    print("------------------------Finish Rewrite------------------------")


def test_simple_enumerate():
    constraints = [UniqueConstraint("users", ["id"], False, 'builtin', None)]
    q_before_str = "select distinct (*) from users where id in (select distinct user_id from projects)"
    test_rewrite_helper(constraints, q_before_str)

def test_redmine_enumerate():
    constraints = Loader.load_constraints("../constraints/redmine")
    q_before_str = 'SELECT issues.id AS t0_r0, issues.tracker_id AS t0_r1, issues.project_id AS t0_r2, \
                    issues.subject AS t0_r3, issues.description AS t0_r4, issues.due_date AS t0_r5, \
                    issues.category_id AS t0_r6, issues.status_id AS t0_r7, issues.assigned_to_id AS t0_r8, \
                    issues.priority_id AS t0_r9, issues.fixed_version_id AS t0_r10, issues.author_id AS t0_r11, \
                    issues.lock_version AS t0_r12, issues.created_on AS t0_r13, issues.updated_on AS t0_r14, \
                    issues.start_date AS t0_r15, issues.done_ratio AS t0_r16, issues.estimated_hours AS t0_r17, \
                    issues.parent_id AS t0_r18, issues.root_id AS t0_r19, issues.lft AS t0_r20, issues.rgt AS t0_r21, \
                    issues.is_private AS t0_r22, issues.closed_on AS t0_r23, issue_statuses.id AS t1_r0, \
                    issue_statuses.name AS t1_r1, issue_statuses.is_closed AS t1_r2, issue_statuses.position AS t1_r3, \
                    issue_statuses.default_done_ratio AS t1_r4, projects.id AS t2_r0, projects.name AS t2_r1, \
                    projects.description AS t2_r2, projects.homepage AS t2_r3, projects.is_public AS t2_r4, \
                    projects.parent_id AS t2_r5, projects.created_on AS t2_r6, projects.updated_on AS t2_r7, \
                    projects.identifier AS t2_r8, projects.status AS t2_r9, projects.lft AS t2_r10, \
                    projects.rgt AS t2_r11, projects.inherit_members AS t2_r12, projects.default_version_id AS t2_r13, \
                    projects.default_assigned_to_id AS t2_r14 FROM issues INNER JOIN projects \
                    ON projects.id = issues.project_id INNER JOIN issue_statuses \
                    ON issue_statuses.id = issues.status_id WHERE projects.status <> 9 \
                    AND (SELECT 1 AS one FROM enabled_modules AS em WHERE em.project_id = projects.id \
                         AND em.name = "issue_tracking") IS NOT NULL AND \
                            projects.is_public = True AND projects.id NOT IN \
                                (SELECT project_id FROM members WHERE user_id IN (6, 13)) \
                            AND issues.is_private = False AND issues.status_id IN \
                                (SELECT id FROM issue_statuses WHERE is_closed = False) \
                                AND issues.id IN (SELECT issues.id FROM issues LEFT OUTER JOIN custom_values \
                                ON custom_values.customized_type = "Issue" AND \
                                custom_values.customized_id = issues.id AND custom_values.custom_field_id = 1 \
                                WHERE custom_values.value IN ("c") AND 1 = 1 AND issues.tracker_id \
                                IN (SELECT tracker_id FROM custom_fields_trackers WHERE custom_field_id = 1) \
                                AND ((SELECT 1 FROM custom_fields AS ifa WHERE ifa.is_for_all = True AND ifa.id = 1) \
                                IS NOT NULL OR issues.project_id IN (SELECT project_id FROM custom_fields_projects \
                                    WHERE custom_field_id = 1))) ORDER BY issues.id DESC LIMIT "$1" OFFSET "$2"'
    test_rewrite_helper(constraints, q_before_str)

def test_add_limit_one_rewrite():
    constraints = [UniqueConstraint("R", ["a", "b"], False, "builtin", "")]
    rewriter = Rewriter()
    rules = [rule.AddLimitOne]
    rewriter.set_rules(rules)

    q_str = 'select * from R where a = 1'
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 0)
    
    q_str = 'select * from R where a = 1 and b = 1' 
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 1)

    q_str = 'select a from R where b = 1 order by a' 
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 1)

    q_str = 'select a from R where b = 1 and c = 1' 
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 1)

    q_str = 'select a from R1 where b = 1 and c = 1' 
    q = RewriteQuery(q_str, parse(q_str))
    rewritten_queries = rewriter.rewrite(constraints, q)
    assert(len(rewritten_queries) == 0)

if __name__ == "__main__":
    #test_get_constraints()
    #test_get_rules()
    #test_simple_enumerate()
    #test_redmine_enumerate()
    test_add_limit_one_rewrite()
