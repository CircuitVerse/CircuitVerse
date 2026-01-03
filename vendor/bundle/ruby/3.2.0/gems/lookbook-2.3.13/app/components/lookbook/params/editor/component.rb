module Lookbook
  module Params
    class Editor::Component < Lookbook::BaseComponent
      renders_many :fields, ->(**attrs) do
        @field_count += 1
        Lookbook::Params::Field::Component.new(**attrs, index: @field_count)
      end

      def initialize(**html_attrs)
        @field_count = -1
        @@input_styles = {}
        super
      end

      def before_render
        fields
      end

      def param_styles
        @css_styles ||= @@input_styles.map do |input_name, styles|
          styles.map { |s| "[data-param-input=#{input_name}] #{s}" }.join("\n")
        end.join("\n")
      end

      def self.add_styles(input, styles)
        @@input_styles = {} unless defined?(@@input_styles)
        @@input_styles[input] ||= styles
      end

      protected

      def alpine_component
        "paramsEditorComponent"
      end
    end
  end
end
