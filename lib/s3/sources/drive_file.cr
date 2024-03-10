require "./reader"

module S3
  module Sources
    class DriveFile < Reader(::DriveFile)
      private def update_record_source(updated_source : S3::PresignedSource)
        AppDatabase.exec("
          UPDATE drive_files
            SET
              source_url = $2,
              source_signature_duration = $3,
              source_signature_created_at = $4
            WHERE id = $1
        ",
          resource.id,
          updated_source.url,
          updated_source.expires,
          updated_source.created_at
        )
      end
    end
  end
end
