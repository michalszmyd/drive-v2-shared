module S3
  class PresignedSource
    getter url : String
    getter expires : Int32?
    getter created_at : Time?

    def initialize(@url, @expires, @created_at)
    end

    def expired?
      return true if (expires.nil? || created_at.nil?)

      created_at.not_nil!.to_unix + expires.not_nil! <= Time.utc.to_unix
    end
  end
end
