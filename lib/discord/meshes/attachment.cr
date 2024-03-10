module Discord
  module Meshes
    struct Attachment
      property id, filename, url, content_type

      def initialize(
        @id : String,
        @filename : String,
        @url : String,
        @content_type : String? = nil
      )
      end
    end
  end
end
