module Lookbook
  class EmbedCodeDropdown::Component < Lookbook::BaseComponent
    attr_reader :preview, :pages, :params, :target, :policy

    def initialize(preview:, target:, pages:, params:, policy:, **html_attrs)
      @preview = preview
      @target = target
      @pages = pages
      @policy = policy
      @params = params.deep_symbolize_keys
      super(**html_attrs)
    end

    def app_path
      helpers.lookbook_home_url
    end

    def preview_name
      preview.preview_class_name
    end

    def external_embed_params
      permitted = params.select { |key, val| key.to_s != "_display" }
      permitted.transform_keys! { |key| "param-#{key}" }
    end

    def embed_code
      embed_tag = content_tag("lookbook-embed",
        app: app_path,
        preview: preview_name,
        scenario: target.name,
        **external_embed_params) { "" }
      escape_once embed_tag
    end

    def embed_url
      props = {
        preview: preview_name,
        scenario: target.name,
        **external_embed_params.transform_keys { |k| k.tr("-", "_") }
      }.to_json
      "#{app_path}embed?props=#{CGI.escape(props)}"
    end

    private

    def alpine_component
      "embedCodeDropdownComponent"
    end
  end
end
