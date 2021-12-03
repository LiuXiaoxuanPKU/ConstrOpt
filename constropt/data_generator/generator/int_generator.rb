require_relative '../../constr_extractor/model/constraint'

class IntGenerator
  def initialize; end

  def gen(col, constraints)
    numerical_c = constraints.select { |c| c.is_a?(NumericalConstraint) }
    raise "[Eorror] More than one numerical constraint on field #{col.field}" unless numerical_c.length <= 1

    if !numerical_c.empty?
      numerical_c = numerical_c[0]
      v = Random.rand(numerical_c.min, numerical_c.max)
    else
      v = Random.rand(0, 100) # give it a default range
    end
    v
  end
end
