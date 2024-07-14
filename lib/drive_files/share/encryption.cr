module DriveFiles
  module Share
    module Encryption
      struct EncryptionHMACPayload
        property id : Int32 | Int64
        property expires : Int32
        property date : String
        property algorithm : String
        property signature : String

        def initialize(
          @id,
          @expires,
          @date,
          @algorithm,
          @signature
        )
        end

        def to_url_params
          ["id=#{id}", "expires=#{expires}", "date=#{date.gsub(" ", "%20")}", "algorithm=#{algorithm}", "signature=#{signature}"].join("&")
        end
      end

      KEY = ENV["SECRET_SHARE_SHA"]
    end
  end
end
