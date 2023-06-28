require 'spec_helper'
require 'support/ruby_saml_support'

describe DeviseSamlAuthenticatable::SamlConfig do
  include RubySamlSupport

  let(:saml_config) { controller.saml_config }
  let(:controller) { Class.new { include DeviseSamlAuthenticatable::SamlConfig }.new }

  context "when config/idp.yml does not exist" do
    before do
      allow(Rails).to receive(:root).and_return("/railsroot")
      allow(File).to receive(:exists?).with("/railsroot/config/idp.yml").and_return(false)
    end

    it "is the global devise SAML config" do
      Devise.saml_configure do |settings|
        settings.assertion_consumer_logout_service_binding = 'test'
      end
      expect(saml_config).to be(Devise.saml_config)
      expect(saml_config.assertion_consumer_logout_service_binding).to eq('test')
    end

    context "when the idp_providers_adapter key exists" do
      before do
        Devise.idp_settings_adapter = idp_providers_adapter
      end

      let(:saml_config) { controller.saml_config(idp_entity_id) }
      let(:idp_providers_adapter) {
        Class.new {
          extend RubySamlSupport

          def self.settings(idp_entity_id)
            #some hash of stuff (by doing a fetch, in our case, but could also be a giant hash keyed by idp_entity_id)
            if idp_entity_id == "http://www.example.com"
              base = {
                assertion_consumer_service_url: "acs_url",
                assertion_consumer_service_binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
                name_identifier_format: "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
                issuer: "sp_issuer",
                idp_entity_id: "http://www.example.com",
                authn_context: "",
                idp_cert: "idp_cert"
              }
              with_ruby_saml_1_12_or_greater(proc {
                base.merge!(
                  idp_slo_service_url: "idp_slo_url",
                  idp_sso_service_url: "idp_sso_url",
                )
              }, else_do: proc {
                base.merge!(
                  idp_slo_target_url: "idp_slo_url",
                  idp_sso_target_url: "idp_sso_url",
                )
              })
              base
            elsif idp_entity_id == "http://www.example.com_other"
              base = {
                assertion_consumer_service_url: "acs_url_other",
                assertion_consumer_service_binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST_other",
                name_identifier_format: "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress_other",
                issuer: "sp_issuer_other",
                idp_entity_id: "http://www.example.com_other",
                authn_context: "_other",
                idp_cert: "idp_cert_other"
              }
              with_ruby_saml_1_12_or_greater(proc {
                base.merge!(
                  idp_slo_service_url: "idp_slo_url_other",
                  idp_sso_service_url: "idp_sso_url_other",
                )
              }, else_do: proc {
                base.merge!(
                  idp_slo_target_url: "idp_slo_url_other",
                  idp_sso_target_url: "idp_sso_url_other",
                )
              })
              base
            else
              {}
            end
          end
        }
      }

      context "when a specific idp_entity_id is requested" do
        let(:idp_entity_id) { "http://www.example.com" }
        it "uses the settings from the adapter for that idp" do
          expect(saml_config.idp_entity_id).to eq (idp_entity_id)
          with_ruby_saml_1_12_or_greater(proc {
            expect(saml_config.idp_sso_service_url).to eq('idp_sso_url')
          }, else_do: proc {
            expect(saml_config.idp_sso_target_url).to eq('idp_sso_url')
          })
          expect(saml_config.class).to eq OneLogin::RubySaml::Settings
        end
      end

      context "when another idp_entity_id is requested" do
        let(:idp_entity_id) { "http://www.example.com_other" }
        it "returns the other idp settings" do
          expect(saml_config.idp_entity_id).to eq (idp_entity_id)
          with_ruby_saml_1_12_or_greater(proc {
            expect(saml_config.idp_sso_service_url).to eq('idp_sso_url_other')
          }, else_do: proc {
            expect(saml_config.idp_sso_target_url).to eq('idp_sso_url_other')
          })
          expect(saml_config.class).to eq OneLogin::RubySaml::Settings
        end
      end
    end
  end

  context "when config/idp.yml exists" do
    let(:idp_yaml) {
      yaml = <<-IDP
---
environment:
  assertion_consumer_logout_service_binding: assertion_consumer_logout_service_binding
  assertion_consumer_logout_service_url: assertion_consumer_logout_service_url
  assertion_consumer_service_binding: assertion_consumer_service_binding
  assertion_consumer_service_url: assertion_consumer_service_url
  attributes_index: attributes_index
  authn_context: authn_context
  authn_context_comparison: authn_context_comparison
  authn_context_decl_ref: authn_context_decl_ref
  certificate: certificate
  compress_request: compress_request
  compress_response: compress_response
  double_quote_xml_attribute_values: double_quote_xml_attribute_values
  force_authn: force_authn
  idp_cert: idp_cert
  idp_cert_fingerprint: idp_cert_fingerprint
  idp_cert_fingerprint_algorithm: idp_cert_fingerprint_algorithm
  idp_entity_id: idp_entity_id
  issuer: issuer
  name_identifier_format: name_identifier_format
  name_identifier_value: name_identifier_value
  passive: passive
  private_key: private_key
  protocol_binding: protocol_binding
  security: security
  sessionindex: sessionindex
  sp_name_qualifier: sp_name_qualifier
      IDP
    with_ruby_saml_1_12_or_greater(proc { yaml << <<SERVICE_URLS }, else_do: proc { yaml << <<TARGET_URLS })
  idp_slo_service_url: idp_slo_service_url
  idp_sso_service_url: idp_sso_service_url
SERVICE_URLS
  idp_slo_target_url: idp_slo_service_url
  idp_sso_target_url: idp_sso_service_url
TARGET_URLS
      yaml
    }
    before do
      allow(Rails).to receive(:env).and_return("environment")
      allow(Rails).to receive(:root).and_return("/railsroot")
      allow(File).to receive(:exists?).with("/railsroot/config/idp.yml").and_return(true)
      allow(File).to receive(:read).with("/railsroot/config/idp.yml").and_return(idp_yaml)
    end

    it "uses that file's contents" do
      expect(saml_config.assertion_consumer_logout_service_binding).to eq('assertion_consumer_logout_service_binding')
      expect(saml_config.assertion_consumer_logout_service_url).to eq('assertion_consumer_logout_service_url')
      expect(saml_config.assertion_consumer_service_binding).to eq('assertion_consumer_service_binding')
      expect(saml_config.assertion_consumer_service_url).to eq('assertion_consumer_service_url')
      expect(saml_config.attributes_index).to eq('attributes_index')
      expect(saml_config.authn_context).to eq('authn_context')
      expect(saml_config.authn_context_comparison).to eq('authn_context_comparison')
      expect(saml_config.authn_context_decl_ref).to eq('authn_context_decl_ref')
      expect(saml_config.certificate).to eq('certificate')
      expect(saml_config.compress_request).to eq('compress_request')
      expect(saml_config.compress_response).to eq('compress_response')
      expect(saml_config.double_quote_xml_attribute_values).to eq('double_quote_xml_attribute_values')
      expect(saml_config.force_authn).to eq('force_authn')
      expect(saml_config.idp_cert).to eq('idp_cert')
      expect(saml_config.idp_cert_fingerprint).to eq('idp_cert_fingerprint')
      expect(saml_config.idp_cert_fingerprint_algorithm).to eq('idp_cert_fingerprint_algorithm')
      expect(saml_config.idp_entity_id).to eq('idp_entity_id')
      with_ruby_saml_1_12_or_greater(proc {
        expect(saml_config.idp_slo_service_url).to eq('idp_slo_service_url')
        expect(saml_config.idp_sso_service_url).to eq('idp_sso_service_url')
      }, else_do: proc {
        expect(saml_config.idp_slo_target_url).to eq('idp_slo_service_url')
        expect(saml_config.idp_sso_target_url).to eq('idp_sso_service_url')
      })
      expect(saml_config.issuer).to eq('issuer')
      expect(saml_config.name_identifier_format).to eq('name_identifier_format')
      expect(saml_config.name_identifier_value).to eq('name_identifier_value')
      expect(saml_config.passive).to eq('passive')
      expect(saml_config.private_key).to eq('private_key')
      expect(saml_config.protocol_binding).to eq('protocol_binding')
      expect(saml_config.security).to eq('security')
      expect(saml_config.sessionindex).to eq('sessionindex')
      expect(saml_config.sp_name_qualifier).to eq('sp_name_qualifier')
    end
  end
end
