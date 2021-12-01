class ClassNode
  # name, string
  # parent, ClassNode
  # constants, [Object]
  # ast, # YARD::Parser::Ruby::AstNode

  # table, string
  # children, [ClassNode]

  # constraints, [Constraint]
  attr_accessor :name, :parent, :constants, :ast, :table, :children, :constraints

  def initialize(name)
    @table = nil
    @name = name
    @children = []
    @constraints = []
  end

  def to_s
    "name: #{@name}"
  end
end

# def build(asts)
#     mp = {}
#     roots = []
#     # new nodes
#     for ast in asts
#         for name in get_class_name(ast)
#             node = ClassNode()
#             node.name = name
#             node.parent = get_parent(node)
#             mp[node.name] = node
#     # connect
#     for node in mp
#         parent = mp[node].parent
#         if parent
#             node.parent = mp[parent]
#             mp[parent].children.append(mp[node])
#         else
#             roots.append(mp[parent])
#     # set table name
#     for root in roots
#         dfs(root, root.name)

#     def dfs(root, table)
#         root.table = table
#         for child in root.children
#             dfs(child, table)
