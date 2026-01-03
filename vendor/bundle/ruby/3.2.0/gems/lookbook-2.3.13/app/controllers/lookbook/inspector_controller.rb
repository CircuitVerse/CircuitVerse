module Lookbook
  class InspectorController < Lookbook::ApplicationController
    include TargetableConcern
    include WithPanelsConcern
    include WithPreviewControllerConcern

    def self.controller_path
      "lookbook/inspector"
    end

    def show
      raise_not_found("Preview not found") unless @target

      @main_panels = main_panels
      @drawer_panels = drawer_panels
    end
  end
end
