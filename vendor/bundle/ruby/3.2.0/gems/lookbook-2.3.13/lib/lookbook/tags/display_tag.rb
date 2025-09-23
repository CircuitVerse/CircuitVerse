module Lookbook
  class DisplayTag < YardTag
    def key
      parts.first
    end

    def value
      parts.second
    end

    def parts
      @parts ||= KeyValueTagParser.call(text)
    end
  end
end
