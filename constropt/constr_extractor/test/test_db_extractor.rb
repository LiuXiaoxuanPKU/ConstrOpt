require_relative '../constraint'
require_relative '../engine'
require_relative '../traversor'
require_relative '../db_extractor'

class CollectConstraint
  attr_accessor :table_constraint_map

  def initialize
    @table_constraint_map = Hash.new
  end
  
  def visit(node, _params)
    @table_constraint_map[node.table] = node.constraints
  end
end

def test_app
  app_unique_stats = Hash.new
  app_unique_stats["forem"] = 85
 

  appname = "forem"
  engine = Engine.new("test/data/#{appname}_models")
  root = engine.run
  db_extractor = DBExtractor.new("test/data/#{appname}_db/schema.rb")
  t = Traversor.new(db_extractor)
  t.traverse(root)
  puts "db_extractor: #{db_extractor.unique_cnt}"
  
  visitor = CollectConstraint.new
  t = Traversor.new(visitor)
  t.traverse(root)
  constraints = visitor.table_constraint_map.values.flatten(1)
  unique_c = constraints.select{|c| c.is_a? UniqueConstraint}
  raise "Expect #{app_unique_stats[appname]} unique constraints defined in DB,\
       get #{unique_c.length}" unless unique_c.length == app_unique_stats[appname]
end

test_app
