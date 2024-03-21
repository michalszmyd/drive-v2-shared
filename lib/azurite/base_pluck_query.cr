require "./base_query"

module Azurite
  struct ResultId
    property id : Int64

    def initialize(@id)
    end

    DB.mapping({
      id: Int64
    })
  end

  class BasePluckQuery < BaseQuery(ResultId)
    getter table_name : String
    getter key : String

    def initialize(@table_name, @key = "id")
      super("#{@key} AS id")
    end

    def ids
      map { |result| result.id.as(Int64) }
    end
  end
end
