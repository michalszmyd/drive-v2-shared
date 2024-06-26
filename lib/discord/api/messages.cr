module Discord
  module API
    class Messages
      alias DiscordAttachment = File

      def self.get(channel_id : String, id : String, &)
        client = Client.new("/channels/#{channel_id}/messages/#{id}")

        client.get do |payload_response|
          json = payload_response.json

          message = Meshes::Message.new(
            id: json["id"].as_s,
            content: json["content"].as_s,
            channel_id: json["channel_id"].as_s,
            attachments: json["attachments"].as_a
          )

          yield message
        end
      end

      def self.create(channel_id : String, content : String, attachment : DiscordAttachment? = nil, &)
        form = Forms::Multipart.new

        io = form.build do |builder|
          builder.field("content", content)

          if attachment
            builder.file(
              "file",
              attachment.tempfile,
              HTTP::FormData::FileMetadata.new(filename: attachment.filename)
            )
          end
        end

        client = Client.new("/channels/#{channel_id}/messages")
        client.request_headers.add("Content-Type", "multipart/form-data; boundary=#{form.boundary}")

        client.post(io.to_s) do |payload_response|
          json = payload_response.json

          message = Meshes::Message.new(
            id: json["id"].as_s,
            content: json["content"].as_s,
            channel_id: json["channel_id"].as_s,
            attachments: json["attachments"].as_a?
          )

          yield message
        end
      end
    end
  end
end
