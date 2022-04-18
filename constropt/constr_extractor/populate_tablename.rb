require 'active_support/core_ext/string'
require 'active_support/inflector'

class PopulateTableName
  def get_tablename_from_ast(ast, default_table_name)
    return nil if ast.nil?

    ast[2].children.each do |c|
      # self.table = "#{table_name_prefix}users#{table_name_suffix}"
      # self.table = "#{table_name_prefix}workflows#{table_name_suffix}"
      # assume table_name_prefix, table_name_suffix are all empty for now
      next unless c.type.to_s == 'assign' && c[0].source.include?('self.table')
      tablename = c[1].source.dup
      tablename.slice! '"' # remove leading "
      tablename.slice! ':' # remove leading :
      tablename.slice! '"' # remove end "
      tablename.slice! "\#{table_name_prefix}"
      tablename.slice! "\#{table_name_suffix}"

      if c[0].source == "self.table_name_prefix"
        default_table_name = default_table_name.split('/')[-1]
        tablename = tablename + default_table_name
      end
      tablename.slice! '\'' # remove leading '
      tablename.slice! '\'' # remove end '
      return tablename
    end
    nil
  end

  def visit(node, params)
    return if ['ActiveRecord::Base', 'ApplicationRecord', 'DummyRoot', 'RailsSettings::Base'].include? node.name

    custom_tablename = get_tablename_from_ast(node.ast, node.name.tableize)
    if custom_tablename
      node.table = custom_tablename
      params['table_name'] = node.table
      return
    end

    if params.key? 'table_name'
      node.table = params['table_name']
      return
    end

    node.table = node.name.tableize
    params['table_name'] = node.table
  end
end
