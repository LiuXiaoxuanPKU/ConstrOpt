
def extract_create_stmt(lines):
    i = 0
    create_statments = []
    while i < len(lines):
        line = lines[i]
        if line.startswith("--"):
            i += 4
            if i >= len(lines):
                break
            action_line = lines[i]
            if action_line.startswith("CREATE TABLE"):
                create_stmt = action_line
                while action_line != '\n':
                    i += 1
                    action_line = lines[i]
                    create_stmt += action_line
                create_statments.append(create_stmt)
        i += 1
    return create_statments

def remove_public_tablename(stmts):
    remove_stmts = []
    for stmt in stmts:
        lines = stmt.split("\n")
        tokens = lines[0].split(" ")
        assert(tokens[2].startswith("public."))
        tokens[2] = tokens[2].split('.')[-1]
        line0 = " ".join(tokens)
        lines[0] = line0
        remove_stmt = "\n".join(lines)
        remove_stmts.append(remove_stmt)
    return remove_stmts

def remove_default(stmts):
    remove_stmts = []
    for stmt in stmts:
        lines = stmt.split("\n")
        remove_stmt = []
        for line in lines:
            tokens = line.split(" ")
            if "DEFAULT" in tokens:
                default_idx = tokens.index("DEFAULT")
                tokens[default_idx] = ''
                if tokens[default_idx + 1].endswith(","):
                    tokens[default_idx + 1] = ","
                else:
                    tokens[default_idx + 1] = ''
                if default_idx + 2 < len(tokens):
                    if tokens[default_idx + 2].startswith('varying'):
                        tokens[default_idx + 2] = tokens[default_idx + 2][len('varying'):]
                line = " ".join(tokens)
                # TODO: make sure not null is in the line
            remove_stmt.append(line)
        remove_stmt = "\n".join(remove_stmt)
        remove_stmts.append(remove_stmt)
    return remove_stmts
      

def replace_keyword(stmts):
    keywords = {"text": "character varying(255)",
                "bytea": "binary(255)"}
    replace_stmts = []
    for stmt in stmts:
        lines = stmt.split("\n")
        replace_stmt = []
        for line in lines:
            tokens = line.split(" ")
            for keyword in keywords:
                if keyword in tokens:
                    keyword_id = tokens.index(keyword)
                    tokens[keyword_id] = keywords[keyword]
                elif keyword + ',' in  tokens:
                    keyword_id = tokens.index(keyword + ",")
                    tokens[keyword_id] = keywords[keyword] + ","
            line = " ".join(tokens)
            replace_stmt.append(line)
        replace_stmt = "\n".join(replace_stmt)
        replace_stmts.append(replace_stmt)
    return replace_stmts

def add_quote_keyword(stmts):
    keywords = ["language", "filter", "value", "default_value"]
    comment_stmts = []
    for stmt in stmts:
        lines = stmt.split("\n")
        comment_stmt = []
        for line in lines:
            tokens = line.split(" ")
            for keyword in keywords:
                if keyword in tokens:
                    keyword_id = tokens.index(keyword)
                    tokens[keyword_id] = '"' + tokens[keyword_id] + '"'
            line = " ".join(tokens)
            comment_stmt.append(line)
        comment_stmt = "\n".join(comment_stmt)
        comment_stmts.append(comment_stmt)
    return comment_stmts

def dump_stmts(appname, stmts):
    outname = appname + "_create.sql"
    with open(outname, 'w') as f:
        for stmt in stmts:
            f.write(stmt)

if __name__ == "__main__":
    appname = "redmine"
    with open(appname, "r") as f: 
        lines = f.readlines()
    create_stmts = extract_create_stmt(lines)
    create_stmts = remove_public_tablename(create_stmts)
    create_stmts = remove_default(create_stmts)
    create_stmts = add_quote_keyword(create_stmts)
    create_stmts = replace_keyword(create_stmts)
    dump_stmts(appname, create_stmts)