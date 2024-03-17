
module Azurite
  class BaseQuery(T)
    include Enumerable(T)

    class RecordNotFound < Exception
    end

    getter select_clause : String = "*"
    getter from_clause : String

    @limit_value : Int32?

    def initialize(
      @select_clause : String?,
      @from_clause : String,
    )
      @where_conditions = [] of WhereCondition
      @limit_value = nil
    end

    def find(id)
      record = where({"id" => id}).first?

      raise RecordNotFound.new("Record not found") unless record

      record
    end

    def first?
      results[0]?
    end

    def limit(value : Int32)
      @limit_value = value

      self
    end

    def where_not(value : Hash | String, args : (Array(WhereConditionType))? = [] of Int32)
      where(value, args, compare: "!=")
    end

    def where_nil(value : String)
      @where_conditions.push(
        WhereCondition.new(
          column_condition: value,
          value: nil,
          input_type: :pretty,
          compare: "IS"
        )
      )

      self
    end

    def where_not_nil(value : String)
      @where_conditions.push(
        WhereCondition.new(
          column_condition: value,
          value: nil,
          input_type: :pretty,
          compare: "IS NOT"
        )
      )

      self
    end

    def where(value : Hash | String, args : (Array(WhereConditionType))? = [] of Int32, compare : String = "=")
      if value.is_a?(Hash)
        value.keys.each do |key|
          @where_conditions.push(WhereCondition.new(column_condition: key, value: value[key], input_type: :pretty, compare: compare))
        end
      else
        raise "Args are empty" if args.empty?

        @where_conditions.push WhereCondition.new(column_condition: value, value: args[0], input_type: :standard, compare: compare)
      end

      self
    end

    def each(&block : T -> _)
      results.each(&block)
    end

    def results
      params = execute_params

      AppDatabase.query_all(params[:sql], args: params[:args], as: T)
    end

    def execute_params
      args = [] of WhereConditionType
      index_of_where_parameter = 0

      where_condition = @where_conditions.map_with_index do |where, index|
        if where.value.nil?
          where.to_query
        else
          args.push(where.value)
          where.to_query(index_of_where_parameter += 1)
        end
      end.join(" AND ")

      where_clause = where_condition.blank? ? "" : "WHERE #{where_condition}"
      limit = @limit_value ? "LIMIT #{@limit_value}" : ""

      {
        sql:"SELECT #{select_clause} FROM #{from_clause} #{where_clause} #{limit}",
        args: args
      }
    end
  end
end
