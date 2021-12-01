require_relative '../../constr_extractor/model/class_node'
require_relative '../../constr_extractor/model/constraint'
require_relative '../util/topo_sorter'

def test_naive
  # dependency + inheritance graph
  #      A
  #   B --> C
  #    \
  #     ---> E
  #  D
  # expect order: A, C, E, B, D
  nodeA = ClassNode.new('A')
  nodeB = ClassNode.new('B')
  nodeC = ClassNode.new('C')
  nodeD = ClassNode.new('D')
  nodeE = ClassNode.new('E')
  nodeA.children = [nodeB, nodeC]
  nodeB.parent = nodeA
  nodeC.parent = nodeA
  nodeB.children = [nodeD]
  nodeD.parent = nodeB
  nodeC.children = [nodeE]
  nodeE.parent = nodeC
  nodeB.constraints = [ForeignKeyConstraint.new('C_id', 'C'), ForeignKeyConstraint.new('E_id', 'E')]

  sorter = TopoSorter.new
  name_refclass_map = sorter.extract_depends(nodeA)
  puts name_refclass_map
  nodes, depends = sorter.get_nodes_list_and_depends(nodeA, name_refclass_map)

  ordered_nodes = sorter.sort(nodes, depends)

  raise 'TOPO error ' unless ordered_nodes[0] == nodeA
  raise 'TOPO error ' unless ordered_nodes[1] == nodeC
  raise 'TOPO error ' unless ordered_nodes[2] == nodeE
  raise 'TOPO error ' unless ordered_nodes[3] == nodeB
  raise 'TOPO error ' unless ordered_nodes[4] == nodeD
end

test_naive
