module Lookbook
  # Helpers for rendering UI elements.
  #
  # These are available for use in documentation page templates
  # and custom preview inspector panel templates.
  #
  # @api public
  module UiElementsHelper
    # Render an icon.
    #
    # Lookbook uses icons from the [Lucide Icons](https://lucide.dev/) set and
    # a full list of available icon names can be found on that site.
    #
    # @example
    #   <%= icon :trash %>
    #   <%= icon :camera, size: 6, style: "color: red;" %>
    #
    # @param name [Symbol, String] Name of the icon
    # @param opts [Hash] Options hash
    def icon(name, **opts)
      lookbook_render(:icon, name: name, **opts)
    end

    # Display a syntax-highlighted block of code.
    #
    # An alternative to using markdown code blocks for templates that have
    # markdown parsing disabled, or for when more control is required.
    #
    # @param language [Symbol] Which language the code is written in
    # @param opts [Hash] Options hash
    # @param block [Proc] Code block
    def code(language = :html, **opts, &block)
      opts[:language] ||= language
      lookbook_render :code, **opts, &block
    end

    # @api private
    def prose(**opts, &block)
      lookbook_render(:prose, **opts, &block)
    end

    # @api private
    def lookbook_tag(tag = :div, **attrs, &block)
      lookbook_render(:tag, tag: tag, **attrs, &block)
    end

    # @api private
    def lookbook_render(ref, **attrs, &block)
      comp = if ref.is_a? ViewComponent::Base
        ref
      else
        klass = component_class(ref)
        attrs.key?(:content) ? klass.new(**attrs.except(:content)).with_content(attrs[:content]) : klass.new(**attrs)
      end
      if block && !attrs.key?(:content)
        public_send render_method_name, comp, &block
      else
        public_send render_method_name, comp
      end
    end

    private

    COMPONENT_CLASSES = {} # cache for constantized references

    # @api private
    def render_method_name
      if Rails.application.config.view_component.render_monkey_patch_enabled || Rails.version.to_f >= 6.1
        :render
      else
        :render_component
      end
    end

    # @api private
    def component_class(ref)
      klass = COMPONENT_CLASSES[ref]
      if klass.nil?
        ref = ref.to_s.tr("-", "_")
        class_namespace = ref.camelize
        begin
          klass = "Lookbook::#{class_namespace}::Component".constantize
        rescue
          klass = "Lookbook::#{class_namespace}Component".constantize
        end
        COMPONENT_CLASSES[ref] = klass
      end
      klass
    end
  end
end
