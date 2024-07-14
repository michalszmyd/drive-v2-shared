module DriveFiles
  module Share
    class Write
      include Share::Encryption

      EXPIRES = 84600

      getter drive_file : DriveFile

      def initialize(@drive_file)
      end

      def call
        signature = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA256, KEY, payload)

        encrypted_hmac_payload = EncryptionHMACPayload.new(
          id: drive_file.id,
          expires: EXPIRES,
          date: Time.utc.to_s,
          algorithm: "SHA256",
          signature: signature
        )

        yield encrypted_hmac_payload
      end

      private def payload
        {
          "id"        => drive_file.id,
          "expires"   => EXPIRES,
          "date"      => Time.utc.to_s,
          "algorithm" => "SHA256",
        }.to_json
      end
    end
  end
end
