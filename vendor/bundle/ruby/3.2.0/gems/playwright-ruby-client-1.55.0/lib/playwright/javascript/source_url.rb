module Playwright
  module JavaScript
    class SourceUrl
      # @param source [String]
      # @param path [String]
      def initialize(source, path)
        @source = source
        @source_url = path.to_s.gsub("\n", '')
      end

      def to_s
        "#{@source}\n//# sourceURL=#{@source_url}"
      end
    end
  end
end
