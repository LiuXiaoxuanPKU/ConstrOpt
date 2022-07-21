class Constraint:
    def __init__(self, table, field, db) -> None:
        self.table = table
        self.field = field
        self.db = db

    def __eq__(self, __o: object) -> bool:
        return self.__hash__() == __o.__hash__()

    def __hash__(self) -> int:
        return hash(str(self))

class UniqueConstraint(Constraint):
    def __init__(self, table, field, db, type, cond) -> None:
        if table == "principals":
            table = "users"

        super().__init__(table, field, db)
        self.cond = cond
        assert(type in ["pk", "has_one", "builtin", "db-index"])
        self.type = type

    def __str__(self) -> str:
        return "Unique_table_%s_field_%s_cond_%s" % (self.table, '_'.join(self.field), self.cond)


class InclusionConstraint(Constraint):
    def __init__(self, table, field, db, values) -> None:
        if table == "principals":
            table = "users"
        super().__init__(table, field, db)
        self.value_list = values

    def __str__(self) -> str:
        if len(self.value_list) == 0:
            value_list_str = 'None'
        else:
            value_str_list = [str(e) for e in self.value_list]
            value_list_str = '|'.join(value_str_list)
        return "Inclusion_table_%s_field_%s_valuelist_%s" % (self.table, self.field, value_list_str)


class LengthConstraint(Constraint):
    def __init__(self, table, field, db, min, max) -> None:
        super().__init__(table, field, db)
        self.min = min
        self.max = max

    def __str__(self) -> str:
        return "Length_table_%s_field_%s_min_%s_max_%s" % (self.table, self.field, self.min, self.max)


class FormatConstraint(Constraint):
    def __init__(self, table, field, db, format) -> None:
        super().__init__(table, field, db)
        self.format = format

    def __str__(self) -> str:
        return "Format_table_%s_field_%s_format_%s" % (self.table, self.field, self.format)


class PresenceConstraint(Constraint):
    def __init__(self, table, field, db) -> None:
        super().__init__(table, field, db)

    def __str__(self) -> str:
        return "Presence_table_%s_field_%s" % (self.table, self.field)


class NumericalConstraint(Constraint):
    def __init__(self, table, field, db, min, max) -> None:
        super().__init__(table, field, db)
        self.min = min
        self.max = max
        if self.min is None and self.max is None:
            print("[Error] Numerical Constraint, Min and Max cannot be None at the same time")
        #     raise Exception(
        #         "[Error] Numerical Constraint, Min and Max cannot be None at the same time")

    def in_range(self, v):
        if self.min and self.max:
            return self.min <= v and v <= self.max
        if self.min:
            return self.min <= v
        if self.max:
            return v <= self.max

    def __str__(self) -> str:
        return "Numerical_table_%s_field_%s_min_%s_max_%s" % (self.table, self.field, self.min, self.max)


class ForeignKeyConstraint(Constraint):
    def __init__(self, table, field, db, ref_class) -> None:
        super().__init__(table, field, db)
        self.ref_class = ref_class
    
    def __str__(self) -> str:
        return "ForeignKey_table_%s_field_%s_refclass_%s" % (self.table, self.field, self.ref_class) 
    