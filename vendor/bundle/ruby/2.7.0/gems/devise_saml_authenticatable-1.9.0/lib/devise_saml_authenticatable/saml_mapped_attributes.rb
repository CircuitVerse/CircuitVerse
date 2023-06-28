module SamlAuthenticatable
  class SamlMappedAttributes
    def initialize(attributes, attribute_map)
      @attributes = attributes
      @attribute_map = attribute_map
    end

    def saml_attribute_keys
      @attribute_map.keys
    end

    def resource_keys
      @attribute_map.values
    end

    def value_by_resource_key(key)
      str_key = String(key)

      # Find all of the SAML attributes that map to the resource key
      attribute_map_for_key = @attribute_map.select { |_, resource_key| String(resource_key) == str_key }

      saml_value = nil

      # Find the first non-nil value
      attribute_map_for_key.each_key do |saml_key|
        saml_value = value_by_saml_attribute_key(saml_key)

        break unless saml_value.nil?
      end

      saml_value
    end

    def value_by_saml_attribute_key(key)
      @attributes[String(key)]
    end
  end
end
