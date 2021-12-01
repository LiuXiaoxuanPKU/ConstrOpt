require 'json'
require 'oj'
require_relative 'constraint'
require_relative 'class_node'

class TreeVisitor
  attr_accessor :constraints

  def initialize
    @constraints = []
  end

  def visit(node, _params)
    c = Serializer.serialize_node(node)
    @constraints << c
  end
end

class Serializer
  def self.deserialize_node(node_obj)
    node = ClassNode.new(node_obj['name'])
    node.parent = node_obj['parent']
    node.constants = node_obj['constants']
    node.ast = node_obj['ast']
    node.table = node_obj['table']
    node.children = node_obj['children']
    node.constraints = Oj.load(node_obj['constraints'])
    node
  end

  def self.serialize_node(node)
    node.constraints.each do |c|
      c.cond = c.cond.to_s if c.class.method_defined? :cond
    end
    {
      table: node.table,
      class: node.name,
      constraints: Oj.dump(node.constraints)
    }.to_json
  end

  def self.deserialize_tree(filename)
    file = File.read(filename)
    data_hash = JSON.parse(file)
    nodes = []
    name_node_map = {}
    data_hash.each do |node_obj|
      node = deserialize_node(node_obj)
      name_node_map[node_obj['name']] = node
      nodes << node
    end
    root = nil
    nodes.each do |node|
      if name_node_map.key? node.parent
        node.parent = name_node_map[node.parent]
      else
        node.parent = nil
        root = node
      end
      children = []
      node.children.each do |childname|
        children << name_node_map[childname]
      end
      node.children = children
    end
    root
  end

  def self.serialize_tree(root, output_filename)
    visitor = TreeVisitor.new
    t = Traversor.new(visitor)
    t.traverse(root)
    File.open(output_filename, 'w') do |f|
      JSON.dump(visitor.constraints, f)
    end
  end
end
