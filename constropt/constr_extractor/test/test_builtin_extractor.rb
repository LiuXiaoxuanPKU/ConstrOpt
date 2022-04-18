require 'yard'
require_relative '../builtin_extractor'
require_relative '../class_node'

def test_naive
  puts "==============Test Naive=============="
  class_def = <<-FOO
    class Test
        validates_presence_of :login, :firstname, :lastname
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  builtin_extractor = BuiltinExtractor.new
  builtin_extractor.visit(node, {})
  puts "# of extracted constraints: #{node.constraints.length}"
end

def test_validates
  puts "==============Test Validates=============="
  class_def = <<-FOO
    class Test
        validates :name,
            uniqueness: { scope: [:project_id], case_sensitive: false },
            length: { maximum: 255 }
        validates :badge_id, uniqueness: { scope: :user_id }
        validates :badge_image, presence: true
        validates :title, presence: true, uniqueness: true
        validates :type_of, inclusion: {in: %w[Announcement Welcome]}
        validates :body_markdonw, length: { in: 256 }
        validates :commentable_id, presence: true, if: :commentable_type
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  builtin_extractor = BuiltinExtractor.new
  builtin_extractor.visit(node, {})
  raise "Get #{node.constraints.length} extracted constraints, expect 13" unless node.constraints.length == 13
  puts "extracted constraints: #{node.constraints}"
end

def test_multiple_validate
  puts "=============Test Multiple Validate======="
  class_def = <<-FOO
    class Test
      validates :estimated_hours, :numericality => {:greater_than_or_equal_to => 2, :allow_nil => true, :message => :invalid}
      validates :example1, :example2, :example3, :numericality => {:greater_than_or_equal_to => 2, :allow_nil => true, :message => :invalid}
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  builtin_extractor = BuiltinExtractor.new
  builtin_extractor.visit(node, {})
  raise "Get #{node.constraints.length} extracted constraints, expect 4" unless node.constraints.length == 4

  puts "extracted constraints: #{node.constraints}" 
end

def test_numerical
  puts "==============Test Numerical=============="
  class_def = <<-FOO
    class Test
      validates_inclusion_of :default_done_ratio, in: 0..100, allow_nil: true
      validates :estimated_hours, :numericality => {:greater_than_or_equal_to => 2, :allow_nil => true, :message => :invalid}
      validates_numericality_of :port, :only_integer => true, :allow_nil => true
      validates :min_length, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :experience_level, numericality: { less_than_or_equal_to: 10 }, allow_blank: true
      validates_numericality_of :timeout, :only_integer => true, :allow_blank => true
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  builtin_extractor = BuiltinExtractor.new
  builtin_extractor.visit(node, {})
  raise "Get #{node.constraints.length} extracted constraints, expect 7" unless node.constraints.length == 7 

  puts "extracted constraints: #{node.constraints}" 
end


test_naive
test_validates
test_multiple_validate
test_numerical
