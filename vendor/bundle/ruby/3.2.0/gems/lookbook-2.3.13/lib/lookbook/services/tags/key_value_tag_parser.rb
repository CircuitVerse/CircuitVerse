module Lookbook
  class KeyValueTagParser < Service
    KEY_VALUE_REGEX = /^([^\s]+)\s+(.+)$/

    attr_reader :text

    def initialize(text)
      @text = text.to_s
    end

    def call
      text.strip.match(KEY_VALUE_REGEX) do |matches|
        key = matches[1]
        value = begin
          YAML.safe_load(matches[2] || "~")
        rescue ::Psych::SyntaxError => exception
          raise ParserError.new("Invalid YAML in tag text '#{@text}'", scope: "key_value_tag.parser", original: exception)
        end
        return [key, value]
      end
      raise ParserError.new("Could not parse key:value pair from '#{@text}'", scope: "key_value_tag.parser")
    end
  end
end
