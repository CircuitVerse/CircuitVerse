module Lookbook
  module WithPanelsConcern
    extend ActiveSupport::Concern

    included do
      private

      def main_panel_names
        Lookbook.config.preview_inspector.main_panels
      end

      def drawer_panel_names
        Lookbook.config.preview_inspector.drawer_panels
      end

      def main_panels
        Engine.panels.get_panels(*main_panel_names).map do |config|
          PanelStore.resolve_config(config, inspector_data)
        end
      end

      def drawer_panels
        panels = Engine.panels.get_panels(*drawer_panel_names)
        panels.select { |config| !config.name.to_s.in?(main_panel_names) }.map do |config|
          PanelStore.resolve_config(config, inspector_data)
        end
      end
    end
  end
end
