require_relative '../../constr_extractor/model/class_node'
require_relative '../../constr_extractor/model/constraint'
require_relative '../../constr_extractor/controller/traversor'

class DependExtractor
  attr_accessor :name_refclass_map

  def initialize
    @name_refclass_map = {}
  end

  def visit(node, _params)
    fk_constraints = node.constraints.select { |c| c.is_a?(ForeignKeyConstraint) }
    fk_constraints.each do |c|
      @name_refclass_map[node.name] = [] unless @name_refclass_map.key? node.name
      @name_refclass_map[node.name].append(c.ref_class)
    end
  end
end

class NodeListExtractor
  attr_accessor :nodes, :node_depend_map

  def initialize(name_refclass_map)
    @nodes = {}
    @name_refclass_map = name_refclass_map
    @node_depend_map = {}
  end

  def visit(node, _params)
    @nodes[node.name] = node
  end

  def post_visit(_root)
    @name_refclass_map.each do |name, ref_classes|
      @node_depend_map[@nodes[name]] = []
      ref_classes.each do |ref_class|
        @node_depend_map[@nodes[name]].append(@nodes[ref_class])
      end
    end
    @nodes = @nodes.values
  end
end

class TopoSorter
  # output {classname: refclassname}
  def extract_depends(root)
    depend_extractor = DependExtractor.new
    t = Traversor.new(depend_extractor)
    t.traverse(root)
    depend_extractor.name_refclass_map
  end

  def get_nodes_list_and_depends(root, name_refclass_map)
    nodelist_extractor = NodeListExtractor.new(name_refclass_map)
    t = Traversor.new(nodelist_extractor)
    t.traverse(root)
    [nodelist_extractor.nodes, nodelist_extractor.node_depend_map]
  end

  def build_out_degree_map(depends, class_nodes)
    out_degree_map = {}
    class_nodes.each do |node|
      out_degree_map[node] = if !node.parent.nil?
                               1
                             else
                               0
                             end
      out_degree_map[node] += depends[node].length if depends.key? node
    end
    out_degree_map
  end

  def get_q_str(q)
    q_str = ''
    q.each do |node|
      q_str += node.to_s + ' '
    end
    q_str
  end

  def get_degree_map_str(m)
    m_str = "start map\n"
    m.each do |k, v|
      m_str += "key #{k}, value #{v}\n"
    end
    m_str += "-----\n"
    m_str
  end

  def reverse_depends(depends)
    reverse_depends = {}
    depends.each do |k, vs|
      vs.each do |v|
        reverse_depends[v] = [] unless reverse_depends.key? v
        reverse_depends[v].append(k)
      end
    end
    reverse_depends
  end

  # input: [ClassNode], Hash (depends)
  # output: [ClassNode] (ordered)
  def sort(class_nodes, depends)
    out_degree_map = build_out_degree_map(depends, class_nodes)
    depends_reverse = reverse_depends(depends)
    # puts "reverse depend map #{get_degree_map_str(depends_reverse)}"
    # puts "org out degree map #{get_degree_map_str(out_degree_map)}"
    q = []
    out_degree_map.each do |k, v|
      q << k if v.zero?
    end
    result = []
    until q.empty?
      node = q[0]
      q = q.drop(1)
      result << node
      depend_nodes = if depends_reverse.key? node
                       (node.children + depends_reverse[node]).uniq
                     else
                       node.children
                     end
      # puts "depend nodes #{get_q_str(depend_nodes)}"
      # puts "drop node #{node}, cur q #{get_q_str(q)}"
      depend_nodes.each do |child|
        out_degree_map[child] -= 1
        # puts "out degree map #{get_degree_map_str(out_degree_map)}"
        q.push(child) if out_degree_map[child].zero?
        # puts "push node #{child}, cur q #{get_q_str(q)}" if out_degree_map[child].zero?
      end
    end
    result
  end
end
