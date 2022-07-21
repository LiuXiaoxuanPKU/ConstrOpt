import json

with open("redmine_perf", "r") as f:
    lines = f.readlines()

for line in lines:
    obj = json.loads(line)
    sp = obj["t_db"] / max(obj["t_rewrite_constraint"], 1e-5)
    if sp < 1.1:
        print(sp)
        print(obj["raw"])
        print(obj["rewrite"])
        print("=================")