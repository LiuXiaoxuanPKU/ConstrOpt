import json

with open('openproject', 'r') as f:
  data = json.load(f)

trues = 0
falses = 0
overlaps = 0

for d in data:
    cons = d['constraints']
    dbs = []
    for x in cons:
        db = x.pop('db')
        if db:
            trues += 1
        else:
            falses += 1
        dbs.append(db)

    for i in range(len(cons)-1):
        for j in range(i+1, len(cons)):
            if cons[i] == cons[j] and dbs[i] != dbs[j]:
                overlaps += 1

print("t", trues, "f", falses, "o", overlaps)
