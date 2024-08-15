require 'spec_helper'
require 'devise_saml_authenticatable/saml_mapped_attributes'

describe SamlAuthenticatable::SamlMappedAttributes do
  let(:instance) { described_class.new(saml_attributes, attribute_map) }
  let(:attribute_map_file) { File.join(File.dirname(__FILE__), '../support/attribute-map.yml') }
  let(:attribute_map) { YAML.load(File.read(attribute_map_file)) }
  let(:saml_attributes) do
    {
      "first_name" => ["John"],
      "last_name"=>["Smith"],
      "email"=>["john.smith@example.com"]
    }
  end

  describe "#value_by_resource_key" do
    RSpec.shared_examples "correctly maps the value of the resource key" do |saml_key, resource_key, expected_value|
      subject(:perform) { instance.value_by_resource_key(resource_key) }

      it "correctly maps the resource key, #{resource_key}, to the value of the '#{saml_key}' SAML key" do
        saml_attributes[saml_key] = saml_attributes.delete(resource_key)
        expect(perform).to eq(expected_value)
      end
    end

    context "first_name" do
      saml_keys = ['urn:mace:dir:attribute-def:first_name', 'first_name', 'firstName', 'firstname']

      saml_keys.each do |saml_key|
        include_examples 'correctly maps the value of the resource key', saml_key, 'first_name', ['John']
      end
    end

    context 'last_name' do
      saml_keys = ['urn:mace:dir:attribute-def:last_name', 'last_name', 'lastName', 'lastname']

      saml_keys.each do |saml_key|
        include_examples 'correctly maps the value of the resource key', saml_key, 'last_name', ['Smith']
      end
    end

    context 'email' do
      saml_keys = ['urn:mace:dir:attribute-def:email', 'email_address', 'emailAddress', 'email']

      saml_keys.each do |saml_key|
        include_examples 'correctly maps the value of the resource key', saml_key, 'email', ['john.smith@example.com']
      end
    end
  end
end