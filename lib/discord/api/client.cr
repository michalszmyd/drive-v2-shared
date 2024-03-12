module Discord
  module API
    class Client
      class RecordError < Exception; end
      class IntegrtionError < Exception; end

      API_KEY = ENV.fetch("DISCORD_API_KEY")
      HOSTING_CHANNEL_ID = ENV.fetch("DISCORD_CHANNEL_ID")
      BASE_URL = "https://discord.com/api"
      AUTHORIZATION_HEADER = "Bot #{API_KEY}"
      DEFAULT_HEADERS = {
        "Authorization": AUTHORIZATION_HEADER,
      }

      getter url : String
      getter request_headers : HTTP::Headers

      @request_headers : HTTP::Headers

      def initialize(@url : String, headers : HTTP::Headers? = nil)
        @request_headers = HTTP::Headers.new
        @request_headers.add("Authorization", AUTHORIZATION_HEADER)
        @request_headers.add("Accept", "application/json")
      end

      def add_header(key : String, value : String)
        request_headers.add(key, value)
      end

      def get
        HTTP::Client.get(
          path,
          headers: request_headers
        ) do |response|
          yield http_response_handle(response)
        end
      end

      def post(body : String | IO::Memory)
        HTTP::Client.post(
          path,
          headers: request_headers,
          body: body
        ) do |response|
          yield http_response_handle(response)
        end
      end

      private def http_response_handle(response)
        if response.status_code >= 200 && response.status_code < 400
          parsed_body = JSON.parse(response.body_io.gets.not_nil!)
          payload_response = PayloadResponse.new(
            json: parsed_body,
            status_code: response.status_code
          )

          payload_response
        elsif response.status_code >= 400 && response.status_code < 500
          raise RecordError.new(response.body_io.gets)
        else
          raise IntegrtionError.new("Server error")
        end
      end

      private def path : String
        "#{BASE_URL}#{url}"
      end
    end
  end
end
