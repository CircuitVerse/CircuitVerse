require "marcel"

module Lookbook
  class FileDataUriEncoder < Service
    attr_reader :path

    def initialize(path, mime_type = nil)
      @path = path
      @mime_type = mime_type
    end

    def content
      File.read(path)
    end

    def mime_type
      @mime_type || Marcel::MimeType.for(Pathname.new(path))
    end

    def call
      DataUriEncoder.call(content, mime_type)
    end
  end
end
