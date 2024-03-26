module Discord
  module API
    module Forms
      class Multipart
        def build(&)
          io = IO::Memory.new
          builder = HTTP::FormData::Builder.new(io, boundary)

          yield builder

          builder.finish

          io
        end

        def boundary
          @boundary ||= MIME::Multipart.generate_boundary
        end
      end
    end
  end
end
