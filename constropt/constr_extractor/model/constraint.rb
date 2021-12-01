# validate.rb in the old repo (formatchecker)
# how to write validate function: https://guides.rubyonrails.org/active_record_validations.html#validates-each
require 'json'
require 'active_support/inflector'

class Constraint
  attr_accessor :class_name, :field_name, :db
end

class InclusionConstraint < Constraint
  attr_accessor :values, :type

  def initialize(field, values, type, db = false)
    @field_name = field
    @values = values
    @type = type
    @db = db
  end
end

class UniqueConstraint < Constraint
  attr_accessor :cond, :case_sensitive, :scope

  def initialize(field, cond, case_sensitive, scope, db = false)
    @field_name = field
    @cond = cond
    @case_sensitive = case_sensitive
    @scope = scope
    @db = db
  end
end

class PresenceConstraint < Constraint
  attr_accessor :cond

  def initialize(field_name, cond, db = false)
    @field_name = field_name
    @cond = cond
    @db = db
  end
end

class LengthConstraint < Constraint
  attr_accessor :min, :max

  def initialize(field_name, min, max, db = false)
    @field_name = field_name
    @min = min
    @max = max
    @db = db
  end
end

class FormatConstraint < Constraint
  attr_accessor :format

  def initialize(field_name, format_regex, db = false)
    @field_name = field_name
    @format = format_regex
    @db = db
  end
end

class ForeignKeyConstraint < Constraint
  attr_accessor :ref_class

  def initialize(field_name, ref_class, db = false)
    @field_name = field_name
    @ref_class = ref_class
    @db = db
  end
end
