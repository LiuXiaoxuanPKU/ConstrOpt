require 'active_support/inflector'
require_relative 'ast_handler'
require_relative 'constraint'

class AssocExtractor
  def extract_cmd(c)
    constraints = []
    ident = c[0].source
    if 'belongs_to'.include? ident
      if c[1].children.length == 1  # belongs_to :field
        field = handle_symbol_literal_node(c[1][0])
        ref_class_name = field.classify
        c = ForeignKeyConstraint.new(field + "_id", ref_class_name)
        constraints.append(c)
      elsif c[1].children.length == 2 # belongs_to :new_status, :class_name => 'IssueStatus'
        field = handle_symbol_literal_node(c[1][0])
        ref_class = c[1][1]
        key, ref_class_name = handle_assoc_node(ref_class[0])
        ref_class_name = ref_class_name.source
        raise "[Error] Fail to parse belong to #{ref_class.source}" unless key == 'class_name'

        c = ForeignKeyConstraint.new(field + "_id", ref_class_name)
        constraints.append(c)
      else
        raise "[Error] Unsupported belong to extract pattern #{c[1].source}"
      end
    end
    constraints
  end

  def visit(node, _params)
    return if node.ast.nil?

    ast = node.ast
    constraints = []
    ast[2].children.each do |c|
      constraints += extract_cmd(c) if c.type.to_s == 'command'
    end
    node.constraints += constraints
  end
end
