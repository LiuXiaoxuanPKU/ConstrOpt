require_relative '../traversor'
require_relative '../class_node'

class TestPrint
  def visit(node, params)
    puts "#{node.name} => #{node.children.map{|c| c.to_s}}"
  end
end

def test_naive
  n0 = ClassNode.new('0')
  n1 = ClassNode.new('1')
  n2 = ClassNode.new('2')
  n3 = ClassNode.new('3')
  n0.children = [n1, n2]
  n2.children = [n3]

  #   TestPrint.print_lambda(n0)
  t = Traversor.new(TestPrint.new)
  t.traverse(n0)
end

test_naive
