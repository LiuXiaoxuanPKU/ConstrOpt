require_relative './generator/str_generator'
require_relative './generator/int_generator'
require_relative './generator/datetime_generator'
require_relative '../constr_extractor/model/column'

class ColumnGenerator
  def initialize
    @null_percentage = 0.2 # set a defulat percentage for null values
    @generators = {
      'StringColumn' => StrGenerator.new,
      'IntegerColumn' => IntGenerator.new,
      'DateTimeColumn' => DatetimeGenerator.new
    }
  end

  def get_field_exist(col, constraints)
    if col.null == false
      return true
    elsif col.null == true
      return false
    end
    # there exists a presence constraint
    return true unless constraints.empty?

    false
  end

  def generate(col, constraints)
    v = @generators[col.class.to_s].gen(col, constraints)
    must_present = get_field_exist(col, constraints)
    # nullify @null_percentage values if the field does not have a present constraint
    v = nil unless must_present && Random.rand < @null_percentage
    v
  end
end
