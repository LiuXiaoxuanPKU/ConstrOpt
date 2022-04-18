require_relative './base_extractor'
require_relative './constraint'

class ClassInheritanceExtractor < Extractor
  def initialize
    @table_value_map = {}
    @table_node_map = {}
  end

  def visit(node, _params)
    if !@table_value_map.key? node.table
      @table_value_map[node.table] = [node.name]
      @table_node_map[node.table] = node
    else
      @table_value_map[node.table].append(node.name)
    end
  end

  def post_visit(_root)
    @table_value_map.each do |table, value|
      next if value.length <= 1

      node = @table_node_map[table]
      db = false
      c = InclusionConstraint.new('type', @table_value_map[node.table], 'class_inheritance', db)
      node.constraints.append(c)
    end
  end
end
