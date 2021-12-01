class GeneratorEngine
  def initialize(root)
    @root = root
    @record_cnt = 100
  end

  def prepare
    # get depends

    # topological sort to get the generate order

    # parse schema
  end

  def generate_by_node(node)
    # {f1: v1, f2: v2}
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
    ordered_classnodes.each do
      node
      records = []
      (1..@record_cnt).each do |_i|
        records << (generate_by_node(node))
      end
      export(records)
    end
  end
end
