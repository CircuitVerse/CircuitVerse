module DeviseSamlAuthenticatable
  class DefaultAttributeMapResolver
    def initialize(saml_response)
      @saml_response = saml_response
    end

    def attribute_map
      return {} unless File.exist?(attribute_map_path)

      attribute_map = YAML.load(File.read(attribute_map_path))
      if attribute_map.key?(Rails.env)
        attribute_map[Rails.env]
      else
        attribute_map
      end
    end

    private

    attr_reader :saml_response

    def attribute_map_path
      Rails.root.join("config", "attribute-map.yml")
    end
  end
end
