from enum import Enum

class FileType(Enum):
    RAW_QUERY = 1
    REWRITE = 2
    CONSTRAINT = 3
    PARAM_QUERY = 4
    REWRITE_PERF = 5
    DB_PERF = 6
    REWRITE_DB_PERF = 7
    VERIFIER_INPUT = 8
    EMPTY_RESULT_QUERY = 9
    VERIFIER_OUTPUT = 10
    PRECHECK_STR2INT_NUM = 11
    
    TEST_PROVE_Q = 12
    
    ENUM_EVAL = 13
  
def get_filename(_type, appname):

    m = {
            # input query, constraint, create table sql
            FileType.TEST_PROVE_Q : "log/%s/prove.sql" % appname,
            FileType.RAW_QUERY : "/home/ubuntu/ConstrOpt/queries/%s/%s.pk" % (appname, appname),
            FileType.CONSTRAINT : "/home/ubuntu/ConstrOpt/constraints/%s"  % (appname),
            FileType.VERIFIER_INPUT : "log/%s/cosette/create.sql" % appname,
            # output sqls for cosette
            FileType.VERIFIER_OUTPUT : "log/%s/cosette/" % appname,   
            # output performance files
            FileType.PARAM_QUERY : "log/%s/all_queries" % appname,
            FileType.REWRITE_PERF : "log/%s/rewrite_perf" % appname,
            FileType.DB_PERF : "log/%s/db_perf" % appname,
            FileType.REWRITE_DB_PERF : "log/%s/db_rewrite_perf" % appname,    
            FileType.EMPTY_RESULT_QUERY: "log/%s/empty_query" % appname,
            FileType.REWRITE : "log/%s/%s_test_rewrite"  % (appname, appname),
            FileType.PRECHECK_STR2INT_NUM : "log/precheck_strtoint_num",
            FileType.ENUM_EVAL : "log/%s/enum_evaluation" % (appname),
    }
    return m[_type]

CONNECT_MAP = {
    "redmine" : "user=redmine password=my_password dbname=redmine_develop",
    "redmine_test" : "user=redmine password=my_password dbname=redmine_test",
    "forem" : "user=ubuntu password=my_password dbname=Forem_development",
    "openproject" : "user=openproject password=my_password dbname=openproject_dev"
}

class RewriteQuery:
    def __init__(self, q_raw, q_obj) -> None:
        self.q_raw = q_raw
        self.q_obj = q_obj # json representation of the query
        self.rewrites = []
        self.q_raw_param = None
        self.estimate_cost = None # cost estimated by the verifier
        
PRIORITY_MAP = {
    "AddPredicate" : 6,
    "RewriteNullPredicate" : 5,
    "RemovePredicate" : 4,
    "RemoveJoin" : 3,
    "RemoveDistinct" : 2,
    "AddLimitOne" : 1,
    "ReplaceOuterJoin": 0,
    "UnionToUnionAll" : -1
}

REWRITE_LIMIT = 10000
