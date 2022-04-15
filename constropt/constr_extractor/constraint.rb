# validate.rb in the old repo (formatchecker)
# how to write validate function: https://guides.rubyonrails.org/active_record_validations.html#validates-each
require 'json'
require 'active_support/inflector'

class Constraint
  attr_accessor :class_name, :field_name, :db, :allow_nil

  def initialize(field, db, allow_nil)
    @field_name = field
    @db = db
    @allow_nil = allow_nil
  end
end

class InclusionConstraint < Constraint
  attr_accessor :values, :type

  def initialize(field, values, type, db = false, allow_nil = false)
    super(field, db, allow_nil)
    @values = values
    @type = type
  end
end

class UniqueConstraint < Constraint
  attr_accessor :cond, :case_sensitive, :scope

  def initialize(field, cond, case_sensitive, scope, db = false, allow_nil = false)
    super(field, db, allow_nil)
    @cond = cond
    @case_sensitive = case_sensitive
    @scope = scope
  end
end

class PresenceConstraint < Constraint
  attr_accessor :cond

  def initialize(field, cond, db = false, allow_nil = false)
    super(field, db, allow_nil)
    @cond = cond
  end
end

class LengthConstraint < Constraint
  attr_accessor :min, :max

  def initialize(field, min, max, db = false, allow_nil = false)
    super(field, db, allow_nil)
    @min = min
    @max = max
  end
end

class FormatConstraint < Constraint
  attr_accessor :format

  def initialize(field, format_regex, db = false, allow_nil = false)
    super(field, db, allow_nil)
    @format = format_regex
  end
end

class NumericalConstraint < Constraint
  attr_accessor :min, :max, :allow_nil

  def initialize(field, min, max, db = false, allow_nil = false)
    super(field, db, allow_nil)
    @min = min
    @max = max
  end
end


class HasManyConstraint < Constraint
  attr_accessor :class_name, :foreign_key, :callable, :dependent, :inverse_of, :through, :as, :extend

  def initialize(field, class_name, foreign_key, callable, dependent, inverse_of, through, as, extend, db = false, allow_nil = false)
    super(field, db, allow_nil)
    @class_name = class_name
    @foreign_key = foreign_key
    @callable = callable
    @dependent = dependent
    @inverse_of = inverse_of
    @through = through
    @as = as
    @extend = extend # what is this???
  end
end

class ForeignKeyConstraint < Constraint
  attr_accessor :class_name, :fk_column_name, :polymorphic

  def initialize(field, class_name, fk_column_name, polymorphic, db = false, allow_nil = true)
    super(field, db, allow_nil)
    @field_name = field
    @class_name = class_name
    @fk_column_name = fk_column_name
    @polymorphic = polymorphic
  end
end

class HasOneManyConstraint < Constraint
  attr_accessor :class_name, :foreign_key, :as_field, :type

  def initialize(field, class_name, foreign_key, as_field, type, through, db=false)
    @field_name = field
    @class_name = class_name
    @foreign_key = foreign_key
    @as_field = as_field
    @db = db
    @type = type
  end
end
