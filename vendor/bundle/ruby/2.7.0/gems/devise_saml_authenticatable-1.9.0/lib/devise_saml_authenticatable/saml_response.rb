require 'devise_saml_authenticatable/saml_mapped_attributes'

module SamlAuthenticatable
  class SamlResponse
    attr_reader :raw_response, :attributes

    def initialize(saml_response, attribute_map)
      @attributes = ::SamlAuthenticatable::SamlMappedAttributes.new(saml_response.attributes, attribute_map)
      @raw_response = saml_response
    end

    def attribute_value_by_resource_key(key)
      attributes.value_by_resource_key(key)
    end
  end
end
