module Lookbook
  module Params
    class Field::Component < Lookbook::BaseComponent
      attr_reader :param, :rendered_input

      def initialize(param:, index:, **html_attrs)
        @param = param
        @index = index
        @rendered_input = nil
        super(**html_attrs)
      end

      def before_render
        styles, html = StylesExtractor.call(render_input)
        Editor::Component.add_styles(param.input, styles)

        escaped_value = html_escape(json_escape(param.value.to_s).gsub("\n", '\n'))
        wrapper_attrs = {
          data: {"param-input": param.input},
          "x-data": "paramsInputComponent({name: \"#{param.name}\", value: \"#{escaped_value}\"})"
        }
        @rendered_input = tag.div(**wrapper_attrs) { html.html_safe }
      end

      protected

      def render_input
        input_options = param.input_options.to_h
        input_options[:id] = "param-#{param.name}"

        render(param.input_partial,
          name: param.name,
          input: param.input,
          value: param.value.to_s,
          value_type: param.value_type,
          value_default: param.value_default,
          input_options: input_options.except(:choices, :opts),
          choices: input_options[:choices])
      end

      def alpine_component
        "paramsFieldComponent"
      end
    end
  end
end
