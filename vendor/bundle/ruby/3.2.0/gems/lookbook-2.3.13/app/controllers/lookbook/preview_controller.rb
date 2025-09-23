require "rails/application_controller"

module Lookbook
  class PreviewController < Rails::ApplicationController
    content_security_policy(false) if respond_to?(:content_security_policy)

    private

    def set_locale(&block)
      I18n.with_locale(params[:locale] || I18n.default_locale, &block)
    end

    # Returns either {} or {layout: value} depending on configuration
    def determine_layout(layout_override = nil, prepend_views: true)
      return {} unless defined?(Rails.root)

      layout_declaration = {}

      if !layout_override.nil?
        # Allow component-level override, even if false (thus no layout rendered)
        layout_declaration[:layout] = layout_override
      elsif default_preview_layout.present?
        layout_declaration[:layout] = default_preview_layout
      end

      prepend_application_view_paths if layout_declaration[:layout].present? && prepend_views

      layout_declaration
    end

    def default_preview_layout
      Lookbook.config.preview_layout
    end

    def prepend_application_view_paths
      prepend_view_path Rails.root.join("app/views") if defined?(Rails.root)
    end

    def prepend_preview_scenarios_view_path
      prepend_view_path(Engine.preview_paths)
    end

    alias_method :prepend_preview_examples_view_path, :prepend_preview_scenarios_view_path
  end
end
