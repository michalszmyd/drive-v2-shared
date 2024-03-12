module Discord
  module Meshes
    struct Message
      property id, content, channel_id, attachments, attachment

      @attachments : Array(Attachment)
      @attachment : Attachment | Nil

      def initialize(
        @id : String,
        @content : String,
        @channel_id : String,
        attachments : Array(JSON::Any) | Nil
      )
        @attachments = attachments ? attachments.map do |element|
          content_type = element["content_type"]?

          Attachment.new(
            id: element["id"].as_s,
            filename: element["filename"].as_s,
            url: element["url"].as_s,
            content_type: content_type ? content_type.as_s : ""
          )
        end : [] of Attachment

        @attachment = @attachments.first?
      end
    end
  end
end
