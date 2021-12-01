require_relative 'base_extractor'
require_relative 'constraint'

class DBExtractor < Extractor
  def initialize(filename)
    @table_dbconstraint_map = extract_from_schema(filename)
  end

  def extract_from_line(line)
    tokens = line.split(',')
    # length constraint
    if line.include? 'limit'
      field = tokens[0].split(' ')[1][1..-2]
      token_with_limit = tokens.filter { |t| t.include? 'limit' }[0]
      limit = token_with_limit['limit'.length..-1].to_i
      return LengthConstraint.new(field, 0, limit, true)
    end
    # presence constraint
    if line.include? 'null: false'
      field = tokens[0].split(' ')[1][1..-2]
      return PresenceConstraint.new(field, nil, true)
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
          c = extract_from_line(line)
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
  end
end
