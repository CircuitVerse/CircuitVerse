module Lookbook
  class YardTag < ::YARD::Tags::Tag
    def initialize(*args)
      if args.size < 2
        tag_name = self.class.name.demodulize.underscore.chomp("_tag")
        super(tag_name, args.first, nil, @name)
      else
        super
      end
    end

    def text
      tag_parts[:text]
    end

    def options
      tag_parts[:options]
    end

    def to_s
      value.to_s
    end

    # The `value` attribute should be overriden in child classes
    # to return the resolved value of the tag, where appropriate.
    # i.e. for the @hidden tag this would return boolean true/false.
    alias_method :value, :text

    def self.supports_options(value = true)
      @supports_options = !!value
    end

    def self.supports_options?
      @supports_options.nil? ? false : @supports_options
    end

    supports_options

    protected

    def tag_parts
      if @tag_parts.nil?
        options, text = parse_options(@text)
      end
      @tag_parts ||= {options: options, text: text}
    end

    def resolve_path(path)
      return unless host_file

      dir = path.start_with?(".") ? host_file.dirname : host_file_base_directory
      Pathname(File.expand_path(path, dir))
    end

    def host_file
      location = object&.files&.first # [file, line_number]
      Pathname(location.first) if location
    end

    def host_file_base_directory
      return unless host_file

      directories = Engine.preview_paths.map(&:to_s).sort_by(&:length).reverse
      directories.first { |dir| host_file.to_s.start_with?(dir) }
    end

    def host_class_instance
      host_class = lookup_host_class
      host_class&.new
    end

    def lookup_host_class
      host_code_object = if object.is_a?(YARD::CodeObjects::MethodObject)
        object.parent
      elsif object.is_a?(YARD::CodeObjects::ClassObject)
        object
      end
      host_code_object&.path&.constantize
    end

    def parse_options(input, resolve: true)
      if self.class.supports_options?
        TagOptionsParser.call(input, {
          file: host_file,
          base_dir: host_file&.dirname,
          eval_context: host_class_instance,
          resolve: resolve
        })
      else
        [{}, @text]
      end
    end
  end
end
