module S3
  class Client
    BUCKET    = ENV["AWS_S3_BUCKET"]
    REGION    = ENV["AWS_S3_REGION"]
    KEY       = ENV["AWS_S3_KEY"]
    SECRET    = ENV["AWS_S3_SECRET"]
    HOST_NAME = "#{BUCKET}.s3.#{REGION}.amazonaws.com"
    EXPIRES   = ENV["AWS_S3_EXPIRES"].to_i32

    def self.new
      @@client ||= Awscr::S3::Client.new(
        REGION,
        KEY,
        SECRET
      )
    end
  end
end
