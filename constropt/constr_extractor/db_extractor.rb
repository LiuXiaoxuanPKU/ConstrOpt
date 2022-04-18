require 'yard'
require_relative 'ast_handler'
require_relative 'base_extractor'
require_relative 'constraint'

class DBExtractor < Extractor
  attr_accessor :unique_cnt
  def initialize(filename)
    @unique_cnt = 0
    @table_dbconstraint_map = extract_from_schema(filename)
    @all_tables = []
  end

  def extract_from_line(line)
    tokens = line.split(',')
    # length constraint
    if line.include? 'limit'
      field = tokens[0].split(' ')[1][1..-2]
      token_with_limit = tokens.select { |t| t.include? 'limit' }[0]
      limit = token_with_limit['limit'.length..-1].to_i
      return LengthConstraint.new(field, 0, limit, db=true), nil
    end
    # presence constraint
    if line.include? 'null: false'
      field = tokens[0].split(' ')[1][1..-2]
      return PresenceConstraint.new(field, nil, db=true), nil
    end

    # 3 "user_subscriptions", "users", column: "subscriber_id"
    # [s(:string_literal, s(:string_content, s(:tstring_content, "user_subscriptions"))), 
    #  s(:string_literal, s(:string_content, s(:tstring_content, "users"))), 
    #  s(s(:assoc, s(:label, "column"), s(:string_literal, s(:string_content, s(:tstring_content, "subscriber_id")))))]
    if line.include? 'add_foreign_key'
      node = YARD::Parser::Ruby::RubyParser.parse(line).root[0][1]
      fk_table = handle_string_literal_node(node.children[0])
      primary_table = handle_string_literal_node(node.children[1])
      if node.children.length == 2
        fk_column = primary_table.singularize + "_id"
        return ForeignKeyConstraint.new(primary_table.singularize, primary_table.classify, fk_column, false, db=true), fk_table
      end

      node.children[2].each do |assoc|
        pair = handle_assoc_node(assoc)
        k, v = pair[0], pair[1]
        if k == 'column'
          fk_column = handle_string_literal_node(v)
        elsif k == 'primary_key'
          puts "[Error] Does not handle primiary column other than id, src: #{line}"
        end
      end

      if fk_column.nil?
        fk_column = primary_table.singularize + "_id"
      end
      return ForeignKeyConstraint.new(primary_table.singularize, primary_table.classify, fk_column, false, db=true), fk_table
    end

    if line.include? 'unique'
      fields = tokens[0].split(' ')
      return nil, nil unless fields[0] == 't.index'    
      @unique_cnt += 1
      node = YARD::Parser::Ruby::RubyParser.parse(line).root[0][3]
      idx_columns = handle_array_node(node.children[0])
      cond = nil
      node.children[1].each do |t|
        assoc = handle_assoc_node(t)
        cond = assoc[1].source if assoc[0] == 'where'
      end
      if idx_columns.nil?
        return nil, nil
      end
      return UniqueConstraint.new(idx_columns, cond, true, "db-index", db=true), nil
    end
    nil
  end

  def extract_from_schema(field_name)
    table_constraint_map = {}
    File.open(field_name, 'r') do |f|
      table_name = nil
      f.each_line do |line|
        if line.include?('create_table')
          table_name = line.split[1][1..-3]
          table_constraint_map[table_name] = []
        else
          c, t = extract_from_line(line)
          table_name = t unless t.nil?
          table_constraint_map[table_name].append(c) unless c.nil?
        end
      end
    end
    table_constraint_map
  end

  def visit(node, _params)
    if @table_dbconstraint_map.key?(node.table)
      node.constraints += @table_dbconstraint_map[node.table]
      @table_dbconstraint_map = @table_dbconstraint_map.except!(node.table)
    end
    @all_tables.append(node.table)
  end

  def post_visit(node)
    @table_dbconstraint_map.each do |table, c|
      if !@all_tables.include? table
        puts "[Error] #{table} does not exist in node tree"
      end
    end
  end
end
