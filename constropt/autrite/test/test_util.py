import os, sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from utils import generate_query_param_single
from config import CONNECT_MAP

def test_single():
    appname = 'redmine'
    sql = 'SELECT members.* FROM members INNER JOIN projects ON projects.id = members.project_id WHERE members.user_id = 3 AND projects.status <> $2 AND members.project_id IS NULL ORDER BY members.id ASC LIMIT 6'
    param_sql = generate_query_param_single(sql, CONNECT_MAP[appname], {})
    print(param_sql)
    assert('$' not in param_sql)
    
if __name__ == "__main__":
    test_single()