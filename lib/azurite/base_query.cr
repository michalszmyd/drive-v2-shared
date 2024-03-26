require "./relations"

module Azurite
  class BaseQuery(T)
    macro table_name(name)
      def table_name
        {{name.stringify}}
      end
    end

    include Relations
    include Enumerable(T)

    class RecordNotFound < Exception
    end

    getter select_clause : String = "*"
    getter joins_conditions : Array(String)

    @limit_value : Int32?
    @offset_value : Int32?
    @order_value : String?
    @where_params : {args: Array(WhereConditionType), where_clause: String}?

    def initialize(
      @select_clause : String?
    )
      @where_conditions = [] of WhereCondition
      @joins_conditions = [] of String
      @limit_value = nil
      @offset_value = nil
      @order_value = nil
      @where_params = nil
    end

    def select(raw)
      @select_clause = raw

      self
    end

    def joins(raw)
      @joins_conditions.push(raw)

      self
    end

    def find(id)
      record = where({"id" => id}).first?

      raise RecordNotFound.new("Record not found") unless record

      record
    end

    def select_count
      args = where_params[:args]
      where_clause = where_params[:where_clause]

      count_sql = "SELECT count(*) FROM #{table_name} #{joins_clause} #{where_clause}"

      count_value = AppDatabase.scalar(count_sql, args: args)

      if count_value.is_a?(Int32)
        count_value
      else
        0
      end
    end

    def first?
      limit(1).results[0]?
    end

    def limit(value : Int32)
      @limit_value = value

      self
    end

    def offset(value : Int32)
      @offset_value = value

      self
    end

    def order(value : String)
      @order_value = value

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

    def each(& : T ->)
      params = execute_params

      AppDatabase.query_each(params[:sql], args: params[:args]) do |element|
        yield element.read T
      end
    end

    def results
      params = execute_params

      records = AppDatabase.query_all(params[:sql], args: params[:args], as: T)

      records
    end

    def execute_params
      limit = @limit_value ? "LIMIT #{@limit_value}" : ""
      offset = @offset_value ? "OFFSET #{@offset_value}" : ""
      order = @order_value ? "ORDER BY #{@order_value}" : ""

      args = where_params[:args]
      where_clause = where_params[:where_clause]

      {
        sql:  "SELECT #{select_clause} FROM #{table_name} #{joins_clause} #{where_clause} #{order} #{limit} #{offset}",
        args: args,
      }
    end

    def joins_clause
      @joins_conditions.empty? ? "" : @joins_conditions.join(" ")
    end

    def where_params
      @where_params ||= begin
        args = [] of WhereConditionType
        index_of_where_parameter = 0

        where_condition = @where_conditions.map do |where|
          if where.value.nil?
            where.to_query
          else
            args.push(where.value)
            where.to_query(index_of_where_parameter += 1)
          end
        end.join(" AND ")

        where_clause = where_condition.blank? ? "" : "WHERE #{where_condition}"

        {
          args:         args,
          where_clause: where_clause,
        }
      end
    end
  end
end
