module Lookbook
  module DisplayOptions
    class Field::Component < Lookbook::BaseComponent
      attr_reader :name, :value

      def initialize(name:, opts:, value:, **html_attrs)
        @name = name
        @opts = opts
        @value = value
        super(**html_attrs)
      end

      def choices
        @opts.is_a?(Hash) ? @opts[:choices].to_a : @opts
      end

      protected

      def alpine_data
        "{name: '#{name}', value: '#{value}'}"
      end

      def alpine_component
        "displayOptionsFieldComponent"
      end
    end
  end
end
