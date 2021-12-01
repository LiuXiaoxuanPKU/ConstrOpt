require 'active_support/core_ext/string'
require 'active_support/inflector'

class PopulateTableName
  def get_tablename_from_ast(ast)
    return nil if ast.nil?

    ast[2].children.select.each do |c|
      # self.table = "#{table_name_prefix}users#{table_name_suffix}"
      # self.table = "#{table_name_prefix}workflows#{table_name_suffix}"
      # assume table_name_prefix, table_name_suffix are all empty for now
      next unless c.type.to_s == 'assign' && c[0].source.include?('self.table')

      tablename = c[1].source.dup
      tablename.slice! '"' # remove leading "
      tablename.slice! '"' # remove end "
      tablename.slice! "\#{table_name_prefix}"
      tablename.slice! "\#{table_name_suffix}"
      return tablename
    end
    nil
  end

  def visit(node, params)
    return if node.name == 'ActiveRecord::Base'

    if params.key? 'table_name'
      node.table = params['table_name']
    else
      custom_tablename = get_tablename_from_ast(node.ast)
      node.table = if custom_tablename.nil?
                     # if the developer does not set the table name, just use the default
                     node.name.tableize
                   else
                     custom_tablename
                   end
      params['table_name'] = node.table
    end
  end
end
