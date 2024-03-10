require "awscr-s3"

module S3
  class File
    getter id : String

    def initialize(@id)
    end

    def presigned_source
      @presigned_source ||= begin
        options = Awscr::S3::Presigned::Url::Options.new(
          aws_access_key: Client::KEY,
          aws_secret_key: Client::SECRET,
          region: Client::REGION,
          object: id,
          bucket: Client::BUCKET,
          host_name: Client::HOST_NAME,
          expires: Client::EXPIRES
        )

        url = Awscr::S3::Presigned::Url.new(options)

        PresignedSource.new(
          url: url.for(:get),
          expires: Client::EXPIRES,
          created_at: Time.utc
        )
      end
    end
  end
end
