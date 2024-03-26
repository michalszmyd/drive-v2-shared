module Azurite
  alias WhereConditionType = String | Int32 | Int64 | Bool | Nil | Time

  struct WhereCondition
    property column_condition : String
    property value : WhereConditionType? = nil
    property input_type : Symbol
    property compare : String = "="

    def initialize(@column_condition, @value, @input_type, @compare)
    end

    def to_query(number : Int32? = 1)
      arg_v = value.nil? ? "NULL" : "$#{number}"

      if input_type == :pretty
        "#{column_condition} #{compare} #{arg_v}"
      else
        "#{column_condition.gsub("?", arg_v)}"
      end
    end
  end
end
