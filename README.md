# `ConstrOpt` Overview
This is the official repository for [Leveraging Applicaton Data Constraints to Optimize Database-Backed Web Applications](https://arxiv.org/abs/2205.02954) by Xiaoxuan Liu, Shuxian Wang, Mengzhu Sun, Sharon Lee, Sicheng Pan, Joshua Wu, Cong Yan, Junwen Yang, and Alvin Chueng. 
Here we present `ConstrOpt`, the first tool that identifies data relationships by analyzing the programs that generate and maintain the persist data. Once identified,`ConstrOpt` leverages the found constraints to optimize the application's physical design and query execution by rewriting queries. Instead of developing a fixed set of predefined rewriting rules, `ConstrOpt` employs an enumerate-test-verify technique to automatically exploit the discovered data constraints to improve query execution. 
## Install
- Install third party libraries for ruby: under `constr_extractor` folder, run
``` 
bundler insatll
```
- Install python dependencies: we use [microsoft z3](https://github.com/Z3Prover/z3) solver to prove sql equivalence. use `pip3 install <package name>` to install the following python3 dependencies. E.g., `pip3 install z3-solver`.

| Package        |
|----------------|
| boto           |
| certifi        |
| mo-dots        |
| mo-future      |
| mo-imports     |
| mo-parsing     |
| mo-sql-parsing |
| psycopg2       |
| tqdm           |
| z3             |
| z3-solver      |

## Experiment
All experiments we did in the paper are under `/autrite` directory. For re-run experiements on redmine, openprojects, and forem, run the following under the root directory. `/autrite/benchmark` directory contains util functions for experiment evaluation. 
```
python3 autrite/pipeline.py --app <appname>
python3 autrite/pipline.py --app redmine  # example
```
The following is the version information we use for apps in our experiments.
| Application | Ruby Version | Release Version/Tag                             |
|-------------|--------------|-------------------------------------------------|
| ConstrOpt   | 3.0.1        | NA                                              |
| Redmine     | 3.0.0        | commit cfba76019b31e22e2de4b1a8b99b201fc31ada29 |
| Dev.to      | 2.7.2        | commit cfba76019b31e22e2de4b1a8b99b201fc31ada29 |
| Openproject | 2.7.4        | commit cfba76019b31e22e2de4b1a8b99b201fc31ada29 |

## Constraint Extractor
Constraint extractor extracts both application constraints and database constraints automatically from the source code. Constraint extractor is under `/constropt/constr_extractor/` directory.
ConstrOpt to extract constraints of different types as shown below.
- Inclusion: the field value is restricted to a limited set.
- Presence: the field value cannot be null. This is the same as the SQL NOT NULL constraint, but is only implicitly defined in the
application code.
- Length: the length of a string field should be in a certain range.
- Uniqueness: same as the SQL uniqueness constraint, but is only
defined in the application.
- Format: the value of a string field must match a regular expres-
sion, which is specified in the application code.
- Numerical: the value of a numerical field must lie in the range
specified in the application code.
- Foreign key: same as the SQL foreign key constraint, where the
field points to the primary key of the referenced table.
#### Run tests
Under the root directory (`\ConstrOpt`), following the following command:
```
cd constropt/constr_extractor/      # enter directory
bundle install                      # install ruby dependencies
chmod +x run_test.sh                # give permisson to this script
./run_test.sh                       # run all tests 
```

## Query Rewriter
ConstrOpt employs an enumerate-test-verify technique to automatically exploit the discovered data constraints to improve query execution. Each resulting rewrite is provably equivalent semantically to the original query. 
#### How to run Rewriter tests
Under root directory, run
```
python3 tests/test.py # run all tests
```
