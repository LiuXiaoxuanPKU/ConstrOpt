def handle_hash_node(node)
  dic = {}
  node.children.each do |child|
    next unless child.type.to_s == 'assoc'

    key, value = handle_assoc_node(child)
    dic[key] = value if key && value
  end
  dic
end

def handle_assoc_node(child)
  key = nil
  value = nil
  key = handle_symbol_literal_node(child[0]) if child[0].type.to_s == 'symbol_literal'
  key = handle_string_literal_node(child[0]) if child[0].type.to_s == 'string_literal'
  key = handle_label_node(child[0]) if child[0].type.to_s == 'label'
  value = child[1]
  ## puts"key: #{key} value: #{value.source}"
  [key, value]
end

def handle_symbol_literal_node(symbol)
  return unless symbol
  return unless symbol.type.to_s == 'symbol_literal'

  symbol[0][0].source
end

def handle_label_node(label)
  label[0]
end

# def handle_array_node(ast)
#   scope = []
#   if ast.type.to_s == "array" || ast.type.to_s == "var_ref"
#     options = nil

#     if ast.type.to_s == "array"
#       options = ast[0]
#     end
#     if ast.type.to_s == "var_ref" && $cur_class.constants.has_key?(ast[0].source) && $cur_class.constants.has_key?(ast[0].source)
#       options = $cur_class.constants[ast[0].source][0]
#     end

#     if options.type.to_s == "list"
#       options.each do |child|
#         if child.type.to_s == "symbol_literal"
#           column = handle_symbol_literal_node(child)
#           scope << column
#         elsif child.type.to_s == "string_literal"
#           column = handle_string_literal_node(child)
#           scope << column
#         elsif child.type.to_s == "var_ref"
#           column = handle_constant_node(child)
#           scope << column
#         end
#       end
#     elsif options.type.to_s == "qsymbols_literal" || options.type.to_s == "qwords_literal"
#       options.children.each do |child|
#         if child.type.to_s == "tstring_content"
#           column = handle_tstring_content_node(child)
#           scope << column
#         end
#       end
#     end
#     return scope # return a list of all possible values
#   end
#   return nil
# end

# def handle_constant_node(ast)
#   if $cur_class.constants.has_key?(ast.source)
#     const_value = $cur_class.constants[ast.source]
#     if const_value.type.to_s == "int"
#       return const_value.source.to_i
#     end
#     return const_value.source
#   end
#   return nil
# end

def handle_tstring_content_node(ast)
  return unless ast

  ast.source if ast&.type.to_s == 'tstring_content'
end

def handle_string_literal_node(ast)
  return unless ast

  if ast&.type.to_s == 'string_literal'
    if ast[0].type == :tstring_content
      ast[0][0].source
    else
      ast[0].source
    end
  end
end

def handle_numeric_literal_node(ast)
  return unless ast

  ast.source if ast&.type.to_s == 'int' || ast&.type.to_s == 'float'
end

def extract_hash_from_list(ast)
  return {} unless ast
  return {} unless ast.type.to_s == 'list'

  dic = {}
  ast.children.each do |child|
    if child.type.to_s == 'assoc'
      key, value = handle_assoc_node(child)
      dic[key] = value
    end
  end
  dic
end
