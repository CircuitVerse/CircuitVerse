module Lookbook
  class DataUriEncoder < Service
    attr_reader :str, :mime_type

    def initialize(str, mime_type)
      @str = str
      @mime_type = mime_type
    end

    def call
      "data:#{mime_type},#{ERB::Util.url_encode(str)}"
    end
  end
end
