module CarrierWave
  module Downloader
    class RemoteFile
      attr_reader :file, :uri

      def initialize(file)
        case file
        when String
          @file = StringIO.new(file)
        when Net::HTTPResponse
          body = file.body
          raise CarrierWave::DownloadError, 'could not download file: No Content' if body.nil?

          @file = StringIO.new(body)
          @content_type = file.content_type
          @headers = file
          @uri = file.uri
        else
          @file = file
          @content_type = file.content_type
          @headers = file.meta
          @uri = file.base_uri
        end
      end

      def content_type
        @content_type || 'application/octet-stream'
      end

      def headers
        @headers || {}
      end

      def original_filename
        filename = filename_from_header || filename_from_uri
        extensions = Marcel::Magic.new(content_type).extensions
        unless File.extname(filename).present? || extensions.blank?
          extension = extensions.first
          filename = "#{filename}.#{extension}"
        end
        filename
      end

    private

      def filename_from_header
        return nil unless headers['content-disposition']

        match = headers['content-disposition'].match(/filename=(?:"([^"]+)"|([^";]+))/)
        return nil unless match

        match[1].presence || match[2].presence
      end

      def filename_from_uri
        CGI.unescape(File.basename(uri.path))
      end

      def method_missing(*args, &block)
        file.send(*args, &block)
      end

      def respond_to_missing?(*args)
        super || file.respond_to?(*args)
      end
    end
  end
end
