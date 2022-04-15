require 'yard'
require_relative '../builtin_extractor'
require_relative '../class_node'

#test defaults
def test_fk_defaults
  class_def = <<-FOO
    class Test
      belongs_to :user
    end
  FOO

  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]

  e = BuiltinExtractor.new
  e.visit(node, {})

  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  class_name = node.constraints[0].class_name
  fk_column_name = node.constraints[0].fk_column_name

  raise "expect class_name = 'User', get #{class_name} instead" unless class_name == 'User'
  raise "expect fk_column_name = 'User', get #{fk_column_name} instead" unless fk_column_name == 'user_id'
end

#test when explicitly stated
def test_fk_explicit
  class_def = <<-FOO
    class Test
      belongs_to :page, :class_name => 'WikiPage', :foreign_key => 'wp_id'
    end
  FOO

  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]

  e = BuiltinExtractor.new
  e.visit(node, {})

  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  class_name = node.constraints[0].class_name
  fk_column_name = node.constraints[0].fk_column_name

  raise "expect class_name = 'WikiPage', get #{class_name} instead" unless class_name == 'WikiPage'
  raise "expect fk_column_name = 'wp_id', get #{fk_column_name} instead" unless fk_column_name == 'wp_id'
end

#test defaults
def test_ho_defaults
  class_def = <<-FOO
    class Test
      has_one :user
    end
  FOO

  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]

  e = BuiltinExtractor.new
  e.visit(node, {})

  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  class_name = node.constraints[0].class_name
  foreign_key = node.constraints[0].foreign_key

  raise "expect class_name = 'User', get #{class_name} instead" unless class_name == 'User'
  raise "expect fk_column_name = 'test_id', get #{foreign_key} instead" unless foreign_key == 'test_id'
end

#test when explicitly stated
def test_ho_explicit
  class_def = <<-FOO
    class Test
      has_one :page, :class_name => 'WikiPage', :foreign_key => 't_id'
    end
  FOO

  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]

  e = BuiltinExtractor.new
  e.visit(node, {})

  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  class_name = node.constraints[0].class_name
  foreign_key = node.constraints[0].foreign_key

  raise "expect class_name = 'WikiPage', get #{class_name} instead" unless class_name == 'WikiPage'
  raise "expect fk_column_name = 't_id', get #{foreign_key} instead" unless foreign_key == 't_id'
end

def test_ho_as
  class_def = <<-FOO
    class Employee < ApplicationRecord
      has_one :picture, as: :imageable
    end
  FOO
  node = ClassNode.new('Employee')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]

  e = BuiltinExtractor.new
  e.visit(node, {})

  as_field = node.constraints[0].as_field

  raise "expect as_field = ':imageable', get #{as_field} instead" unless as_field == 'imageable'
end

def test_fk_polymorphic
  belong_to_def = <<-FOO
    class Picture < ApplicationRecord
      belongs_to :imageable, polymorphic: true
    end
  FOO
  belong_to_node = ClassNode.new('Picture')
  belong_to_node.ast = YARD::Parser::Ruby::RubyParser.parse(belong_to_def).root[0]

  e = BuiltinExtractor.new
  e.visit(belong_to_node, {})

  polymorphic = belong_to_node.constraints[0].polymorphic

  raise "expect polymorphic = 'true', get #{polymorphic} instead" unless polymorphic == true
end

test_fk_defaults
test_fk_explicit
test_ho_defaults
test_ho_explicit
test_ho_as
test_fk_polymorphic
