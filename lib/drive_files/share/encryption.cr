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
      end

      KEY = ENV["SECRET_SHARE_SHA"]
    end
  end
end
