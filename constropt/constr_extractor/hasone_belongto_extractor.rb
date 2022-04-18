# This extractor has two goals
# 1. extract unique constraints from has_one constraint, and put it to the correct node
# 2. extract polymorphic definitions (inclusion constraints) from has_one/has_many + belong_to pairs

require_relative './base_extractor'
require_relative './constraint'

class HasoneBelongtoExtractor < Extractor
  def initialize
    @class_node_map = {}
    @class_constraint_map = {}

    @polyfield_node_map = {}
    @polyfield_valuelist_map = {}
  end

  def visit(node, _params)
    @class_node_map[node.name] = node
    node.constraints.each do |constraint|
      next unless constraint.is_a? HasOneManyConstraint
      next unless constraint.type == 'has_one'
      unless constraint.as_field.nil?
        next
      end # if as field is nil, it's a polymorphic assoc, the unique constriant does not hold anymore

      @class_constraint_map[constraint.class_name.classify] = \
        UniqueConstraint.new([constraint.foreign_key], nil, true, "has_one", db = false)
    end

    # extract polymorphic associations
    node.constraints.each do |constraint|
      next unless constraint.is_a? HasOneManyConstraint  
      next if constraint.as_field.nil?

      @polyfield_valuelist_map[constraint.as_field] = [] unless @polyfield_valuelist_map.include? constraint.as_field
      @polyfield_valuelist_map[constraint.as_field].append(node.name)
    end

    node.constraints.each do |constraint|
      next unless constraint.is_a? ForeignKeyConstraint 
      next unless constraint.polymorphic

      @polyfield_node_map[constraint.field_name.split('_')[0]] = node
    end
  end

  def post_visit(_root)
    # generate unique constraints for has_one
    @class_constraint_map.each do |class_name, constraint|
      unless @class_node_map.include? class_name
        class_name = class_name.split(':')[-1] # Users::Setting
        unless @class_node_map.include? class_name
          puts "[Error] HasoneBelongtoExtractor: Does not have class #{class_name}"
          next
        end
      end
      node = @class_node_map[class_name]
      node.constraints.append(constraint)
    end

    # genreate inclusion constraints for polymorphic assoc
    @polyfield_node_map.each do |field, node|
      unless @polyfield_valuelist_map.include? field
        puts "[Error] Polymorphic: cannot find values for field #{field}"
        next
      end
      value_list = @polyfield_valuelist_map[field]
      inclusion_c = InclusionConstraint.new(field + "_type", value_list, 'polymorphic', db = false)
      node.constraints.append(inclusion_c)
    end
  end
end
