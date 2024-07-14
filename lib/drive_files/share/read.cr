module DriveFiles
  module Share
    class Read
      include Share::Encryption

      getter id : Int32 | Int64
      getter expires : Int32
      getter date : String
      getter algorithm : String
      getter signature : String

      def initialize(
        @id,
        @expires,
        @date,
        @algorithm,
        @signature
      )
      end

      def call
        generated_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA256, KEY, payload)

        return yield nil unless generated_signature == signature
        return yield nil if expired?

        yield id
      end

      private def expired?
        Time.parse(date, "%Y-%m-%d %H:%M:%S %z", Time::Location::UTC) + expires.seconds < Time.utc
      end

      private def payload
        {
          "id"        => id,
          "expires"   => expires,
          "date"      => date,
          "algorithm" => algorithm,
        }.to_json
      end
    end
  end
end
