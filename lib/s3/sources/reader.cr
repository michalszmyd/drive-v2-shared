module S3
  module Sources
    class Reader(T)
      getter resource : T

      def initialize(@resource)
      end

      def url
        external_storage_id = resource.external_storage_id

        return unless external_storage_id

        resource_source = source

        return if resource_source.nil?

        if resource_source.expired?
          updated_presigned_source = S3::File.new(external_storage_id).presigned_source

          update_record_source(updated_presigned_source)

          updated_presigned_source.url
        else
          resource_source.url
        end
      end

      private def update_record_source(updated_source : S3::PresignedSource)
        raise "Not implemented"
      end

      private def source
        source_url = resource.source_url
        source_signature_duration = resource.source_signature_duration
        source_signature_created_at = resource.source_signature_created_at

        return unless source_url

        source = S3::PresignedSource.new(
          url: source_url,
          expires: source_signature_duration,
          created_at: source_signature_created_at
        )
      end
    end
  end
end
