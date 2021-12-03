require_relative './util/schema_parser'
require_relative './util/topo_sorter'
require_relative './generator'

class GeneratorEngine
  def initialize(root)
    @root = root
    @record_cnt = 100
    @column_generator = ColumnGenerator.new
  end

  def prepare
    # topological sort to get the generate order
    sorter = TopoSorter.new
    name_refclass_map = sorter.extract_depends(@root)
    nodes, depends = sorter.get_nodes_list_and_depends(@root, name_refclass_map)
    ordered_nodes = sorter.sort(nodes, depends)

    # parse schema
    parser = SchemaParser.new
    schema = parser.parse

    [ordered_nodes, schema]
  end

  def generate_by_node(node, schema)
    values = {}
    columns = schema[node.name]
    columns.each do |col|
      values[col] = column_generator.generate(col, node.constraint)
    end
    values
  end

  def export(records)
    # Example output
    # data = [
    #   user.create(1)
    #   user.create(2)
    #   user.create(3)
    #   user.create(1)
    #   user.create(4)
    #   user.create(6)
    #   user.create(7)
    #   ]

    #   for r in data:
    #     try
    #     eval(r)
    #     catch:
    #       next
  end

  def generate_db
    ordered_classnodes, schema = prepare
    # generate for each class node, input schema
    ordered_classnodes.each do |node|
      records = []
      (1..@record_cnt).each do |_i|
        records << (generate_by_node(node, schema))
      end
      export(records)
    end
  end
end
