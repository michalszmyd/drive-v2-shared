require "awscr-s3"

module S3
  class UploadFile
    class UploadError < Exception; end

    struct Upload
      property name, unique_id

      def initialize(@name : String, @unique_id : String)
      end
    end

    getter attachment : ::File
    getter name : String

    def initialize(name, @attachment)
      @name = name.gsub('#', "")
    end

    def upload_file
      unique_signature = "#{UUID.random.to_s}-#{name}"

      uploaded = uploader.upload(Client::BUCKET, unique_signature, attachment)

      if uploaded
        yield File.new(unique_signature)
      else
        raise UploadError.new("upload_error")
      end
    end

    private def uploader
      @uploader ||= Awscr::S3::FileUploader.new(Client.new)
    end
  end
end
