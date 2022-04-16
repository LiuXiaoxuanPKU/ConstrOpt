APP = "redmine"
folder = "log/{}/cosette".format(APP)
print(folder)
output = open("{}/verifier-result".format(folder), "r")
queries = open("{}/result.sql".format(folder), "w+")
for line in output:
    file, num = line.split(":")
    with open("{}/eq/{}.sql".format(folder, file)) as q:
        found = False
        for q_line in q:
            if found:
                queries.write(q_line)
                break
            if 'Original Query' in q_line:
                found = True

output.close()
queries.close()