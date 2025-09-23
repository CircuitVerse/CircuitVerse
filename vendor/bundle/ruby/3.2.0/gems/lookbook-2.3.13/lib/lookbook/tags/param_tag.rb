module Lookbook
  class ParamTag < YardTag
    VALUE_TYPE_MATCHER = /^(\[\s?([A-Z]{1}\w+)\s?\])/
    DESCRIPTION_MATCHER = /(?<=\s|^)"(.*?[^\\])"(?:\s|$)/

    supports_options

    attr_reader :tag_args

    def initialize(text)
      @name, text_without_name = extract_name(text)
      @tag_args = parse_tag_body(text_without_name)
      super("param", tag_args[:rest], nil, @name)
    end

    def input
      tag_args[:input]&.downcase&.tr("_", "-")
    end

    def description
      tag_args[:description]
    end

    def value_type
      tag_args[:value_type]&.downcase
    end

    def value_default
      default_value_parts = object.parameters.find { |parts| parts[0].chomp(":") == name }
      if default_value_parts
        # fix issue with YARD argument parser not splitting args correctly (leaving a trailing comma or bracket)
        # when one or more of the argument values is a negative number.
        cleaned_value = default_value_parts[1].start_with?("-") ? default_value_parts[1].sub(/[,\)]$/, "") : default_value_parts[1]
        host_class_instance.instance_eval(cleaned_value)
      else
        raise ParserError.new "Unknown method parameter '#{name}'"
      end
    end

    protected

    def extract_name(text)
      parts = text.to_s.split(" ")
      [parts.shift, parts.join(" ")]
    end

    def parse_tag_body(text)
      value_type = nil
      description = nil

      # Parse out YARD-style value type definition - i.e. [Boolean]
      text.match(VALUE_TYPE_MATCHER) do |match_data|
        value_type = match_data[2]
        text.gsub!(VALUE_TYPE_MATCHER, "").strip!
      end

      # Parse and remove any options from string
      options_str, text = parse_options(text, resolve: false)

      # Parse description, if provided
      text.match(DESCRIPTION_MATCHER) do |match_data|
        description = match_data[1]
        text.sub!(DESCRIPTION_MATCHER, "").strip!
      end

      input, rest = text.split(" ", 2)

      {
        input: input,
        value_type: value_type,
        description: description,
        rest: [rest, options_str].compact.join(" ")
      }
    end
  end
end
