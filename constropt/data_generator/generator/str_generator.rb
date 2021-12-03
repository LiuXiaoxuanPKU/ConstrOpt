require 'regexp-examples'
require_relative '../../constr_extractor/model/constraint'

class StrGenerator
  def initialize
    @idx = 0
  end

  def get_str_len(col, length_constr)
    min = if !length_constr.min.nil?
            length_constr.min
          else
            0
          end
    max = if !length_constr.max.nil? && !col.limit
            [length_constr.max, col.limit].min
          elsif !length_constr.max.nil?
            length_constr.max
          elsif !col.limit
            col.limit
          else
            35 # default string length we assign
          end
    [min, max]
  end

  def get_format_with_length(format, min, max)
    return "\A[A-Za-z0-9]{#{min}, #{max}}\z" if format.nil?

    # remove prefix / and suffix /
    format = format[1...-1] if format.start_with?('/')
    format = format[0...-1] if format.end_with?('/')
    format
  end

  def gen(col, constraints)
    inclusion_c = constraints.select { |c| c.is_a?(InclusionConstraint) }
    raise '[Eorror] More than one inclusion constraint on one field' unless inclusion_c.length <= 1
    if inclusion_c.length > 0
      inclusion_c = inclusion_c[0]
      v = inclusion_c.values[rand(inclusion_c.values.length)] # assume we extract all inclusion values
      return v
    end

    length_c = constraints.select { |c| c.is_a?(LengthConstraint) }
    raise '[Eorror] More than one length constraint on one field' unless length_c.length <= 1

    length_c = if length_c.empty?
                 nil
               else
                 length_c[0]
               end
    min, max = get_str_len(col, length_c)

    format_c = constraints.select { |c| c.is_a?(FormatConstraint) }
    raise '[Eorror] More than one format constraint on one field' unless format_c.length <= 1

    format = if format_c.empty?
               nil
             else
               format_c[0].format
             end
    str_format = get_format_with_length(format, min, max)
    cur_str = /#{str_format}/.examples(max_group_results: 10)[@idx]
    @idx += 1
    cur_str
  end
end
