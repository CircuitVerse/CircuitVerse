require 'rails_helper'
require 'support/ruby_saml_support'

# The important parts from devise
class DeviseController < ApplicationController
  attr_accessor :current_user

  def resource_class
    User
  end

  def resource_name
    'users'
  end

  def require_no_authentication; end

  def set_flash_message!(key, kind, _options = {})
    flash[key] = I18n.t("devise.sessions.#{kind}")
  end
end

class Devise::SessionsController < DeviseController
  def destroy
    sign_out
    redirect_to after_sign_out_path_for(:user), allow_other_host: true
  end
end

require_relative '../../../app/controllers/devise/saml_sessions_controller'

describe Devise::SamlSessionsController, type: :controller do
  include RubySamlSupport
  include Devise::Test::ControllerHelpers

  let(:idp_providers_adapter) { spy('Stub IDPSettings Adaptor') }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    settings = {
      assertion_consumer_service_url: 'acs_url',
      assertion_consumer_service_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
      name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient',
      sp_entity_id: 'sp_issuer',
      idp_entity_id: 'https://www.example.com',
      authn_context: '',
      idp_cert: 'idp_cert'
    }
    with_ruby_saml_1_12_or_greater(proc {
      settings.merge!(
        idp_slo_service_url: 'http://idp_slo_url',
        idp_sso_service_url: 'http://idp_sso_url'
      )
    }, else_do: proc {
      settings.merge!(
        idp_slo_target_url: 'http://idp_slo_url',
        idp_sso_target_url: 'http://idp_sso_url'
      )
    })
    allow(idp_providers_adapter).to receive(:settings).and_return(settings)
  end

  describe '#new' do
    let(:saml_response) do
      File.read(File.join(File.dirname(__FILE__), '../../support', 'response_encrypted_nameid.xml.base64'))
    end

    subject(:do_get) do
      get :new, params: { 'SAMLResponse' => saml_response }
    end

    context 'when using the default saml config' do
      it 'redirects to the IdP SSO target url' do
        do_get
        expect(response).to redirect_to(%r{\Ahttp://localhost:8009/saml/auth\?SAMLRequest=})
      end

      it 'stores saml_transaction_id in the session' do
        do_get
        if OneLogin::RubySaml::Authrequest.public_instance_methods.include?(:request_id)
          expect(session[:saml_transaction_id]).to be_present
        end
      end
    end

    context 'with a specified idp' do
      before do
        Devise.idp_settings_adapter = idp_providers_adapter
      end

      it 'redirects to the associated IdP SSO target url' do
        do_get
        expect(response).to redirect_to(%r{\Ahttp://idp_sso_url\?SAMLRequest=})
      end

      it 'stores saml_transaction_id in the session' do
        do_get
        if OneLogin::RubySaml::Authrequest.public_instance_methods.include?(:request_id)
          expect(session[:saml_transaction_id]).to be_present
        end
      end

      it 'uses the DefaultIdpEntityIdReader' do
        expect(DeviseSamlAuthenticatable::DefaultIdpEntityIdReader).to receive(:entity_id)
        do_get
        expect(idp_providers_adapter).to have_received(:settings).with(nil, request)
      end

      context 'with a relay_state lambda defined' do
        let(:relay_state) { ->(_request) { '123' } }

        it 'includes the RelayState param in the request to the IdP' do
          expect(Devise).to receive(:saml_relay_state).at_least(:once).and_return(relay_state)
          do_get
          expect(response).to redirect_to(%r{\Ahttp://idp_sso_url\?SAMLRequest=.*&RelayState=123})
        end
      end

      context 'with a specified idp entity id reader' do
        class OurIdpEntityIdReader
          def self.entity_id(params)
            params[:entity_id]
          end
        end

        subject(:do_get) do
          get :new, params: { entity_id: 'https://www.example.com' }
        end

        before do
          @default_reader = Devise.idp_entity_id_reader
          Devise.idp_entity_id_reader = OurIdpEntityIdReader # which will have some different behavior
        end

        after do
          Devise.idp_entity_id_reader = @default_reader
        end

        it 'redirects to the associated IdP SSO target url' do
          do_get
          expect(idp_providers_adapter).to have_received(:settings).with('https://www.example.com', request)
          expect(response).to redirect_to(%r{\Ahttp://idp_sso_url\?SAMLRequest=})
        end
      end
    end
  end

  describe '#metadata' do
    let(:saml_config) { Devise.saml_config.dup }

    context 'with the default configuration' do
      it 'generates metadata' do
        get :metadata

        # Remove ID that can vary across requests
        expected_metadata = OneLogin::RubySaml::Metadata.new.generate(saml_config)
        metadata_pattern = Regexp.escape(expected_metadata).gsub(/ ID='[^']+'/, " ID='[\\w-]+'")
        expect(response.body).to match(Regexp.new(metadata_pattern))
      end
    end

    context 'with a specified IDP' do
      let(:saml_config) { controller.saml_config('anything') }

      before do
        Devise.idp_settings_adapter = idp_providers_adapter
        Devise.saml_configure do |settings|
          settings.assertion_consumer_service_url = 'http://localhost:3000/users/saml/auth'
          settings.assertion_consumer_service_binding = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'
          settings.name_identifier_format = 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
          settings.sp_entity_id = 'http://localhost:3000'
        end
      end

      it 'generates the same service metadata' do
        get :metadata

        # Remove ID that can vary across requests
        expected_metadata = OneLogin::RubySaml::Metadata.new.generate(saml_config)
        metadata_pattern = Regexp.escape(expected_metadata).gsub(/ ID='[^']+'/, " ID='[\\w-]+'")
        expect(response.body).to match(Regexp.new(metadata_pattern))
      end
    end
  end

  describe '#destroy' do
    subject { delete :destroy }

    context 'when user is signed out' do
      before do
        class Devise::SessionsController < DeviseController
          def all_signed_out?
            true
          end
        end
      end

      shared_examples 'not create SP initiated logout request' do
        it do
          expect(OneLogin::RubySaml::Logoutrequest).not_to receive(:new)
          subject
        end
      end

      context 'when Devise.saml_sign_out_success_url is set' do
        before do
          allow(Devise).to receive(:saml_sign_out_success_url).and_return('http://localhost:8009/logged_out')
        end

        it 'redirect to saml_sign_out_success_url' do
          is_expected.to redirect_to 'http://localhost:8009/logged_out'
          expect(flash[:notice]).to eq I18n.t('devise.sessions.already_signed_out')
        end

        it_behaves_like 'not create SP initiated logout request'
      end

      context 'when Devise.saml_sign_out_success_url is not set' do
        before do
          class Devise::SessionsController < DeviseController
            def after_sign_out_path_for(_)
              'http://localhost:8009/logged_out'
            end
          end
        end

        it "redirect to devise's after sign out path" do
          is_expected.to redirect_to 'http://localhost:8009/logged_out'
          expect(flash[:notice]).to eq I18n.t('devise.sessions.already_signed_out')
        end

        it_behaves_like 'not create SP initiated logout request'
      end
    end

    context 'when user is not signed out' do
      before do
        class Devise::SessionsController < DeviseController
          def all_signed_out?
            false
          end
        end
        allow(controller).to receive(:sign_out)
      end

      context 'when using the default saml config' do
        it 'signs out and redirects to the IdP' do
          delete :destroy
          expect(controller).to have_received(:sign_out)
          expect(response).to redirect_to(%r{\Ahttp://localhost:8009/saml/logout\?SAMLRequest=})
        end
      end

      context 'when configured to use a non-transient name identifier' do
        before do
          allow(Devise.saml_config).to receive(:name_identifier_format).and_return('urn:oasis:names:tc:SAML:2.0:nameid-format:persistent')
        end

        it 'includes a LogoutRequest with the name identifier and session index', :aggregate_failures do
          controller.current_user = Struct.new(:email).new('user@example.com')
          session[Devise.saml_session_index_key] = 'sessionindex'

          actual_settings = nil
          expect_any_instance_of(OneLogin::RubySaml::Logoutrequest).to receive(:create) do |_, settings|
            actual_settings = settings
            'http://localhost:8009/saml/logout'
          end

          delete :destroy
          expect(actual_settings.name_identifier_value).to eq('user@example.com')
          expect(actual_settings.sessionindex).to eq('sessionindex')
        end
      end

      context 'with a specified idp' do
        before do
          Devise.idp_settings_adapter = idp_providers_adapter
        end

        it 'redirects to the associated IdP SSO target url' do
          expect(DeviseSamlAuthenticatable::DefaultIdpEntityIdReader).to receive(:entity_id)
          delete :destroy
          expect(controller).to have_received(:sign_out)
          expect(response).to redirect_to(%r{\Ahttp://idp_slo_url\?SAMLRequest=})
        end

        context 'with a specified idp entity id reader' do
          class OurIdpEntityIdReader
            def self.entity_id(params)
              params[:entity_id]
            end
          end

          subject(:do_delete) do
            delete :destroy, params: { entity_id: 'https://www.example.com' }
          end

          before do
            @default_reader = Devise.idp_entity_id_reader
            Devise.idp_entity_id_reader = OurIdpEntityIdReader # which will have some different behavior
          end

          after do
            Devise.idp_entity_id_reader = @default_reader
          end

          it 'redirects to the associated IdP SLO target url' do
            do_delete
            expect(controller).to have_received(:sign_out)
            expect(idp_providers_adapter).to have_received(:settings).with('https://www.example.com', request)
            expect(response).to redirect_to(%r{\Ahttp://idp_slo_url\?SAMLRequest=})
          end
        end
      end
    end
  end

  describe '#idp_sign_out' do
    let(:saml_response) { double(:slo_logoutresponse) }
    let(:response_url) { 'http://localhost/logout_response' }
    before do
      allow(OneLogin::RubySaml::SloLogoutresponse).to receive(:new).and_return(saml_response)
      allow(saml_response).to receive(:create).and_return(response_url)
    end

    it 'returns invalid request if SAMLRequest or SAMLResponse is not passed' do
      session[Devise.saml_session_index_key] = 'sessionindex'
      post :idp_sign_out
      expect(response.status).to eq 500
      expect(session[Devise.saml_session_index_key]).to eq('sessionindex')
    end

    context 'when receiving a logout response from the IdP after redirecting an SP logout request' do
      subject(:do_post) do
        post :idp_sign_out, params: { SAMLResponse: 'stubbed_response' }
      end

      it 'accepts a LogoutResponse and redirects sign_in' do
        do_post
        expect(response.status).to eq 302
        expect(response).to redirect_to '/users/saml/sign_in'
      end

      context 'when saml_sign_out_success_url is configured' do
        let(:test_url) { '/test/url' }
        before do
          Devise.saml_sign_out_success_url = test_url
        end

        it 'accepts a LogoutResponse and returns success' do
          do_post
          expect(response.status).to eq 302
          expect(response).to redirect_to test_url
        end
      end
    end

    context 'when receiving an IdP logout request' do
      subject(:do_post) do
        post :idp_sign_out, params: { SAMLRequest: 'stubbed_logout_request' }
      end

      let(:saml_request) do
        double(:slo_logoutrequest, {
                 id: 42,
                 name_id: name_id,
                 issuer: 'https://www.example.com'
               })
      end
      let(:name_id) { '12312312' }
      before do
        allow(OneLogin::RubySaml::SloLogoutrequest).to receive(:new).and_return(saml_request)
        session[Devise.saml_session_index_key] = 'sessionindex'
      end

      it 'direct the resource to reset the session key' do
        do_post
        expect(response).to redirect_to response_url
        expect(session[Devise.saml_session_index_key]).to be_nil
      end

      context 'with a specified idp' do
        let(:idp_entity_id) { 'https://www.example.com' }
        before do
          Devise.idp_settings_adapter = idp_providers_adapter
        end

        it 'accepts a LogoutResponse for the associated slo_target_url and redirects to sign_in' do
          do_post
          expect(response.status).to eq 302
          expect(idp_providers_adapter).to have_received(:settings).with(idp_entity_id, request)
          expect(response).to redirect_to 'http://localhost/logout_response'
          expect(session[Devise.saml_session_index_key]).to be_nil
        end
      end

      context 'with a relay_state lambda defined' do
        let(:relay_state) { ->(_request) { '123' } }

        it 'includes the RelayState param in the request to the IdP' do
          expect(Devise).to receive(:saml_relay_state).at_least(:once).and_return(relay_state)
          do_post
          expect(saml_response).to have_received(:create).with(Devise.saml_config, saml_request.id, nil,
                                                               { RelayState: '123' })
        end
      end

      context 'when saml_session_index_key is not configured' do
        before do
          Devise.saml_session_index_key = nil
        end

        it 'returns invalid request' do
          do_post
          expect(response.status).to eq 500
        end
      end
    end
  end
end
