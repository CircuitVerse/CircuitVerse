module Lookbook
  class PreviewsController < Lookbook::ApplicationController
    include TargetableConcern
    include WithPreviewControllerConcern

    layout false

    before_action :permit_framing, only: [:show]

    def self.controller_path
      "lookbook/previews"
    end

    def index
      respond_to do |format|
        format.json do
          render(
            json: Lookbook.previews.map do |preview|
              {
                name: preview.name,
                scenarios: preview.scenarios.map { |scenario|
                  case scenario
                  when Lookbook::ScenarioEntity
                    scenario_json(scenario)
                  when Lookbook::ScenarioGroupEntity
                    {
                      name: scenario.name,
                      examples: scenario.scenarios.map { |s| scenario_json(s) }
                    }
                  end
                }
              }
            end
          )
        end
      end
    end

    def show
      raise_not_found("Preview not found") unless @target

      @preview_html = if Lookbook.config.preview_single_pass_rendering && !inspector_data.scenarios.many?
        inspector_data.scenarios.first.output + (iframe_content_scripts if embedded?)
      else
        preview_controller.process(
          :render_in_layout_to_string,
          "lookbook/previews/group",
          inspector_data,
          layout: @preview.layout,
          append_html: (iframe_content_scripts if embedded?)
        )
      end
    end

    private

    def embedded?
      params[:lookbook_embed] == "true"
    end

    def iframe_content_scripts
      render_to_string("lookbook/partials/_iframe_content_scripts", layout: nil)
    end

    def scenario_json(scenario)
      {
        name: scenario.name,
        inspect_path: scenario.url_path,
        preview_path: scenario.preview_path
      }
    end

    def permit_framing
      headers["X-Frame-Options"] = Lookbook.config.preview_embeds.policy if embedded?
      headers["X-Frame-Options"] = "SAMEORIGIN" if headers["X-Frame-Options"]&.upcase == "DENY"
    end
  end
end
