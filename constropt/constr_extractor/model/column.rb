class Column
  attr_accessor :field, :table, :default, :null
end

class IntegerColumn < Column
end

class BoolColumn < Column
end

class StringColumn < Column
  # t.string "type", limit: 30
  attr_accessor :limit
  def initialize(field, table, default, null, limit)
    @field = field
    @table = table
    @default = default
    @null = null
    @limit = limit
  end

end

class DateTimeColumn < Column
end
