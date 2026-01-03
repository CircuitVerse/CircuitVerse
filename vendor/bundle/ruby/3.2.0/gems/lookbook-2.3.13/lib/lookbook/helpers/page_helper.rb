module Lookbook
  # Helpers for documentation page templates
  #
  # @api public
  module PageHelper
    # Returns the URL path to a page.
    #
    # @api private
    # @param id [String, PageEntity] The id or PageEntity instance to generate a URL path for
    def page_path(id)
      page = id.is_a?(PageEntity) ? id : Engine.pages.find_by_id(id)
      if page.present?
        page.docs_path
      else
        Lookbook.logger.warn "Could not find page with id ':#{id}'"
      end
    end

    # Render a 'live' embed of a component preview.
    #
    # If no scenario name is provided then the default (first) preview
    # scenario will be rendered in the embed.
    #
    # @param preview [String] Name of the preview class to embed
    # @param scenario [String] Example method name
    # @param opts [Hash] Options hash
    def embed(preview, scenario = nil, **opts)
      preview_entity = if preview.is_a?(Symbol)
        Engine.previews.find_by_path(preview)
      else
        Engine.previews.find_by_preview_class(preview)
      end
      scenario_entity = scenario ? preview_entity&.scenario(scenario) : preview_entity&.default_scenario
      opts[:actions] ||= ["inspect", "open"]

      lookbook_render Embed::Component.new(
        scenario: scenario_entity,
        params: opts.fetch(:params, {}),
        options: opts.except(:params)
      )
    end
  end
end
