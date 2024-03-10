module Discord
  module API
    struct PayloadResponse
      property json, status_code

      def initialize(@json : JSON::Any, @status_code : Int32)
      end
    end
  end
end
