module RSolr
  class Field
    def self.instance(attrs, value)
      attrs = attrs.dup
      field_type = attrs.delete(:type) {  value.class.name }

      klass = if field_type.is_a? String
                class_for_field(field_type)
              elsif field_type.is_a? Class
                field_type
              else
                self
              end

      klass.new(attrs, value)
    end

    def self.class_for_field(field_type)
      potential_class_name = field_type + 'Field'.freeze
      search_scope = Module.nesting[1]
      search_scope.const_defined?(potential_class_name, false) ? search_scope.const_get(potential_class_name) : self
    end
    private_class_method :class_for_field

    # "attrs" is a hash for setting the "doc" xml attributes
    # "value" is the text value for the node
    attr_accessor :attrs, :source_value

    # "attrs" must be a hash
    # "value" should be something that responds to #_to_s
    def initialize(attrs, source_value)
      @attrs = attrs
      @source_value = source_value
    end

    # the value of the "name" attribute
    def name
      attrs[:name]
    end

    def value
      source_value
    end

    def as_json
      if attrs[:update]
        { attrs[:update] => value }
      elsif attrs.any? { |k, _| k != :name }
        hash = attrs.dup
        hash.delete(:name)
        hash.merge(value: value)
      else
        value
      end
    end
  end

  class DateField < Field
    def value
      Time.utc(source_value.year, source_value.mon, source_value.mday).iso8601
    end
  end

  class TimeField < Field
    def value
      source_value.getutc.strftime('%FT%TZ')
    end
  end

  class DateTimeField < Field
    def value
      source_value.to_time.getutc.iso8601
    end
  end

  class DocumentField < Field
    def value
      return RSolr::Document.new(source_value) if source_value.respond_to? :each_pair

      super
    end

    def as_json
      value.as_json
    end
  end
end
