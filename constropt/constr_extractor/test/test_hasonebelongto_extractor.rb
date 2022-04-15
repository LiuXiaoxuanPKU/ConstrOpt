require 'yard'
require_relative '../builtin_extractor'
require_relative '../traversor'
require_relative '../class_node'
require_relative '../hasone_belongto_extractor'

def test_hasone_uniq
  class_dummy = <<-FOO
    class Dummy
    end
  FOO

  class_c1 = <<-FOO
    class C1 < Dummy
      has_one :c2
    end
  FOO

  class_c2 = <<-FOO
    class C2 < Dummy
      belongs_to :c1
    end
  FOO

  node_dummy = ClassNode.new('Dummy')
  node_dummy.ast = YARD::Parser::Ruby::RubyParser.parse(class_dummy).root[0]
  node_c1 = ClassNode.new('C1')
  node_c1.ast = YARD::Parser::Ruby::RubyParser.parse(class_c1).root[0]
  node_c1.parent = node_dummy
  node_c2 = ClassNode.new('C2')
  node_c2.ast = YARD::Parser::Ruby::RubyParser.parse(class_c2).root[0]
  node_c2.parent = node_dummy
  node_dummy.children = [node_c1, node_c2]

  t = Traversor.new(BuiltinExtractor.new)
  t.traverse(node_dummy)
  t = Traversor.new(HasoneBelongtoExtractor.new)
  t.traverse(node_dummy)

  # puts "#{node_c2.constraints}"
  raise "expect 2 constraint, get #{node_c2.constraints.length} constraints" unless node_c2.constraints.length == 2 

  uniq_c = node_c2.constraints.select{|c| c.is_a? UniqueConstraint}
  raise "fail to extract unique constraint" unless uniq_c.length == 1
  uniq_c = uniq_c[0]
  raise "expect field of unique constraint = c1_id, get #{uniq_c.field_name} constraints" unless uniq_c.field_name == 'c1_id' 
end

def test_has_one_polymorphic
  class_dummy = <<-FOO
    class ApplicationRecord
    end
  FOO

  class_c0 = <<-FOO
    class Picture < ApplicationRecord
      belongs_to :imageable, polymorphic: true
    end
  FOO

  class_c1 = <<-FOO
    class Employee < ApplicationRecord
      has_one :pictures, as: :imageable
    end
  FOO

  class_c2 = <<-FOO
    class Product < ApplicationRecord
      has_one :pictures, as: :imageable
    end
  FOO

  node_dummy = ClassNode.new('Dummy')
  node_dummy.ast = YARD::Parser::Ruby::RubyParser.parse(class_dummy).root[0]
  node_c0 = ClassNode.new('C0')
  node_c0.ast = YARD::Parser::Ruby::RubyParser.parse(class_c0).root[0]
  node_c0.parent = node_dummy
  node_c1 = ClassNode.new('C1')
  node_c1.ast = YARD::Parser::Ruby::RubyParser.parse(class_c1).root[0]
  node_c1.parent = node_dummy
  node_c2 = ClassNode.new('C2')
  node_c2.ast = YARD::Parser::Ruby::RubyParser.parse(class_c2).root[0]
  node_c2.parent = node_dummy
  node_dummy.children = [node_c0, node_c1, node_c2]

  t = Traversor.new(BuiltinExtractor.new)
  t.traverse(node_dummy)
  t = Traversor.new(HasoneBelongtoExtractor.new)
  t.traverse(node_dummy)

  # puts "#{node_c0.constraints}"
  raise "expect 2 constraint, get #{node_c0.constraints.length} constraints" unless node_c0.constraints.length == 2 

  inclusion_c = node_c0.constraints.select{|c| c.is_a? InclusionConstraint}
  raise "fail to extract unique constraint" unless inclusion_c.length == 1
  inclusion_c = inclusion_c[0]
  raise "expect field of unique constraint = c1_id, get #{inclusion_c.field_name} constraints" unless inclusion_c.field_name == 'imageable_type'  
end

def test_has_many_polymorphic
  class_dummy = <<-FOO
    class ApplicationRecord
    end
  FOO

  class_c0 = <<-FOO
    class Picture < ApplicationRecord
      belongs_to :imageable, polymorphic: true
    end
  FOO

  class_c1 = <<-FOO
    class Employee < ApplicationRecord
      has_many :pictures, as: :imageable
    end
  FOO

  class_c2 = <<-FOO
    class Product < ApplicationRecord
      has_many :pictures, as: :imageable
    end
  FOO

  node_dummy = ClassNode.new('Dummy')
  node_dummy.ast = YARD::Parser::Ruby::RubyParser.parse(class_dummy).root[0]
  node_c0 = ClassNode.new('C0')
  node_c0.ast = YARD::Parser::Ruby::RubyParser.parse(class_c0).root[0]
  node_c0.parent = node_dummy
  node_c1 = ClassNode.new('C1')
  node_c1.ast = YARD::Parser::Ruby::RubyParser.parse(class_c1).root[0]
  node_c1.parent = node_dummy
  node_c2 = ClassNode.new('C2')
  node_c2.ast = YARD::Parser::Ruby::RubyParser.parse(class_c2).root[0]
  node_c2.parent = node_dummy
  node_dummy.children = [node_c0, node_c1, node_c2]

  t = Traversor.new(BuiltinExtractor.new)
  t.traverse(node_dummy)
  t = Traversor.new(HasoneBelongtoExtractor.new)
  t.traverse(node_dummy)

  # puts "#{node_c0.constraints}"
  raise "expect 2 constraint, get #{node_c0.constraints.length} constraints" unless node_c0.constraints.length == 2 

  inclusion_c = node_c0.constraints.select{|c| c.is_a? InclusionConstraint}
  raise "fail to extract unique constraint" unless inclusion_c.length == 1
  inclusion_c = inclusion_c[0]
  raise "expect field of unique constraint = c1_id, get #{inclusion_c.field_name} constraints" unless inclusion_c.field_name == 'imageable_type'  
end

def test_skip_through1
  class_dummy = <<-FOO
    class ApplicationRecord
    end
  FOO

  class_c0 = <<-FOO
    class Document < ApplicationRecord
      has_many :sections
      has_many :paragraphs, through: :sections
    end
  FOO

  class_c1 = <<-FOO
    class Section < ApplicationRecord
      belongs_to :document
      has_many :paragraphs
    end
  FOO

  class_c2 = <<-FOO
    class Paragraph < ApplicationRecord
      belongs_to :section
    end
  FOO

  node_dummy = ClassNode.new('ApplicationRecord')
  node_dummy.ast = YARD::Parser::Ruby::RubyParser.parse(class_dummy).root[0]
  node_c0 = ClassNode.new('Document')
  node_c0.ast = YARD::Parser::Ruby::RubyParser.parse(class_c0).root[0]
  node_c0.parent = node_dummy
  node_c1 = ClassNode.new('Section')
  node_c1.ast = YARD::Parser::Ruby::RubyParser.parse(class_c1).root[0]
  node_c1.parent = node_dummy
  node_c2 = ClassNode.new('Paragraph')
  node_c2.ast = YARD::Parser::Ruby::RubyParser.parse(class_c2).root[0]
  node_c2.parent = node_dummy
  node_dummy.children = [node_c0, node_c1, node_c2]

  t = Traversor.new(BuiltinExtractor.new)
  t.traverse(node_dummy)
  t = Traversor.new(HasoneBelongtoExtractor.new)
  t.traverse(node_dummy)

  raise "expect 2 constraint, get #{node_c0.constraints.length} constraints" unless node_c0.constraints.length == 2
  raise "expect 2 constraint, get #{node_c1.constraints.length} constraints" unless node_c1.constraints.length == 2
  raise "expect 1 constraint, get #{node_c2.constraints.length} constraints" unless node_c2.constraints.length == 1
end

def test_skip_through2
  class_dummy = <<-FOO
    class ApplicationRecord
    end
  FOO

  class_c0 = <<-FOO
    class Supplier < ApplicationRecord
      has_one :account
      has_one :account_history, through: :account
    end
  FOO

  class_c1 = <<-FOO
    class Account < ApplicationRecord
      belongs_to :supplier
      has_one :account_history
    end
  FOO

  class_c2 = <<-FOO
    class AccountHistory < ApplicationRecord
      belongs_to :account
    end
  FOO

  node_dummy = ClassNode.new('ApplicationRecord')
  node_dummy.ast = YARD::Parser::Ruby::RubyParser.parse(class_dummy).root[0]
  node_c0 = ClassNode.new('Supplier')
  node_c0.ast = YARD::Parser::Ruby::RubyParser.parse(class_c0).root[0]
  node_c0.parent = node_dummy
  node_c1 = ClassNode.new('Account')
  node_c1.ast = YARD::Parser::Ruby::RubyParser.parse(class_c1).root[0]
  node_c1.parent = node_dummy
  node_c2 = ClassNode.new('AccountHistory')
  node_c2.ast = YARD::Parser::Ruby::RubyParser.parse(class_c2).root[0]
  node_c2.parent = node_dummy
  node_dummy.children = [node_c0, node_c1, node_c2]

  t = Traversor.new(BuiltinExtractor.new)
  t.traverse(node_dummy)
  t = Traversor.new(HasoneBelongtoExtractor.new)
  t.traverse(node_dummy)

  puts "#{node_c1.constraints}"
  puts "#{node_c2.constraints}"
  raise "expect 2 constraint, get #{node_c0.constraints.length} constraints" unless node_c0.constraints.length == 2
  raise "expect 3 constraint, get #{node_c1.constraints.length} constraints" unless node_c1.constraints.length == 3
  raise "expect 2 constraint, get #{node_c2.constraints.length} constraints" unless node_c2.constraints.length == 2 
end

test_hasone_uniq
test_has_one_polymorphic
test_has_many_polymorphic
test_skip_through1
test_skip_through2