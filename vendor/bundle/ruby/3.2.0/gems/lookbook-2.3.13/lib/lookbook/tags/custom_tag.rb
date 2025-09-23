module Lookbook
  class CustomTag < YardTag
    supports_options

    attr_reader :arg_names, :tag_args

    def initialize(tag_name, text = nil, *args)
      tag_definition = Engine.tags.get_tag(tag_name)
      unless tag_definition
        raise ParserError.new "Unknown custom tag type '#{tag_name}'"
      end

      super(tag_name, text.to_s, *args)

      @custom_attributes = Store.new
      @arg_names = tag_definition.options.fetch(:named_args, [])
      @after_parse = tag_definition.options.fetch(:after_parse, nil)

      validate_arg_names

      @tag_args = parse_tag
      @after_parse.call(self) if @after_parse.respond_to?(:call)
    end

    # Method aliases to keep compatability with
    # the original custom tag implementation
    alias_method :tag_body, :text
    alias_method :opts, :options

    protected

    def parse_tag
      text_tokens = Shellwords.split(text)
      values = text_tokens.slice(0, arg_names.size)

      arg_names.map.with_index do |name, i|
        [name.to_sym, values[i]]
      end.to_h
    end

    def validate_arg_names
      arg_names.each do |name|
        if methods.include? name.to_sym
          raise ParserError.new "'#{name}' is a reserved word and cannot be used as an argument name."
        end
      end
    end

    def method_missing(name, *args)
      if name.end_with? "="
        @custom_attributes[name.to_s.chomp("=")] = args.first
      else
        @custom_attributes.public_send(name, *args) || tag_args[name]
      end
    end

    def respond_to_missing?(name, include_private)
      @custom_attributes.key?(name) || tag_args.key?(name) || super
    end
  end
end
