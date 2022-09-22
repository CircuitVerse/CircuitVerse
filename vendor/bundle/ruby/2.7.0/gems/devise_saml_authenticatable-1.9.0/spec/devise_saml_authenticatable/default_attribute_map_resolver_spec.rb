require "spec_helper"
require "devise_saml_authenticatable/default_attribute_map_resolver"

describe DeviseSamlAuthenticatable::DefaultAttributeMapResolver do
  let!(:rails) { class_double("Rails", env: "test", logger: logger, root: rails_root).as_stubbed_const }
  let(:logger) { instance_double("Logger", info: nil) }
  let(:rails_root) { Pathname.new("tmp") }

  let(:saml_response) { instance_double("OneLogin::RubySaml::Response") }
  let(:file_contents) {
    <<YAML
---
firstname: first_name
lastname: last_name
YAML
  }
  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return(file_contents)
  end

  describe "#attribute_map" do
    it "reads the attribute map from the config file" do
      expect(described_class.new(saml_response).attribute_map).to eq(
        "firstname" => "first_name",
        "lastname" => "last_name",
      )
      expect(File).to have_received(:read).with(Pathname.new("tmp").join("config", "attribute-map.yml"))
    end

    context "when the attribute map is broken down by environment" do
      let(:file_contents) {
        <<YAML
---
test:
  first: first_name
  last: last_name
YAML
      }
      it "reads the attribute map from the environment key" do
        expect(described_class.new(saml_response).attribute_map).to eq(
          "first" => "first_name",
          "last" => "last_name",
        )
      end
    end

    context "when the config file does not exist" do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it "is an empty hash" do
        expect(described_class.new(saml_response).attribute_map).to eq({})
      end
    end
  end
end
