# ConstrOpt

## Constraint Extractor
### Install third party libraries
under constr_extractor folder, run
``` 
bundler insatll
```

### Run tests
under constr_extractor folder, run
```
rspec spec/extractor_spec.rb
```

## Query Rewriter
### Run tests
under root folder, run
````
PYTHONPATH="./" python tests/test_rewrite.py # run all tests
PYTHONPATH="./" python tests/test_rewrite.py TestRewrite.test_fn_name # run a single test with name test_fn_name
````