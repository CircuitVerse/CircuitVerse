require 'rails_helper'

describe 'SamlAuthenticatable Routes', type: :routing do
  describe 'GET /users/saml/sign_in (login)' do
    it 'routes to Devise::SamlSessionsController#new' do
      expect(get: '/users/saml/sign_in').to route_to(controller: 'devise/saml_sessions', action: 'new')
      expect(get: new_user_session_path).to route_to(controller: 'devise/saml_sessions', action: 'new')
    end
  end

  describe 'POST /users/saml/auth (session creation)' do
    it 'routes to Devise::SamlSessionsController#create' do
      expect(post: '/users/saml/auth').to route_to(controller: 'devise/saml_sessions', action: 'create')
    end
  end

  describe 'DELETE /users/sign_out (logout)' do
    it 'routes to Devise::SamlSessionsController#destroy' do
      expect(delete: '/users/sign_out').to route_to(controller: 'devise/saml_sessions', action: 'destroy')
      expect(delete: destroy_user_session_path).to route_to(controller: 'devise/saml_sessions', action: 'destroy')
    end
  end

  describe 'GET /users/saml/metadata' do
    it 'routes to Devise::SamlSessionsController#metadata' do
      expect(get: '/users/saml/metadata').to route_to(controller: 'devise/saml_sessions', action: 'metadata')
    end
  end

  describe 'GET /users/saml/idp_sign_out (IdP-initiated logout)' do
    it 'routes to Devise::SamlSessionsController#idp_sign_out' do
      expect(get: '/users/saml/idp_sign_out').to route_to(controller: 'devise/saml_sessions', action: 'idp_sign_out')
    end
  end

  describe 'POST /users/saml/idp_sign_out (IdP-initiated logout)' do
    it 'routes to Devise::SamlSessionsController#idp_sign_out' do
      expect(post: '/users/saml/idp_sign_out').to route_to(controller: 'devise/saml_sessions', action: 'idp_sign_out')
    end
  end

  context 'when saml_route_helper_prefix is "sso"' do
    before(:all) do
      ::Devise.saml_route_helper_prefix = 'sso'

      # A very simple Rails engine
      module SamlRouteHelperPrefixEngine
        class Engine < ::Rails::Engine
          isolate_namespace SamlRouteHelperPrefixEngine
        end

        Engine.routes.draw do
          devise_for :users, module: :devise
        end
      end
    end
    after(:all) do
      ::Devise.saml_route_helper_prefix = nil
    end
    routes { SamlRouteHelperPrefixEngine::Engine.routes }

    describe 'GET /users/saml/sign_in (login)' do
      it 'routes to Devise::SamlSessionsController#new' do
        expect(get: '/users/saml/sign_in').to route_to(controller: 'devise/saml_sessions', action: 'new')
        expect(get: new_sso_user_session_path).to route_to(controller: 'devise/saml_sessions', action: 'new')
      end
    end

    describe 'POST /users/saml/auth (session creation)' do
      it 'routes to Devise::SamlSessionsController#create' do
        expect(post: '/users/saml/auth').to route_to(controller: 'devise/saml_sessions', action: 'create')
      end
    end

    describe 'DELETE /users/sign_out (logout)' do
      it 'routes to Devise::SamlSessionsController#destroy' do
        expect(delete: '/users/sign_out').to route_to(controller: 'devise/saml_sessions', action: 'destroy')
        expect(delete: destroy_sso_user_session_path).to route_to(controller: 'devise/saml_sessions', action: 'destroy')
      end
    end

    describe 'GET /users/saml/metadata' do
      it 'routes to Devise::SamlSessionsController#metadata' do
        expect(get: '/users/saml/metadata').to route_to(controller: 'devise/saml_sessions', action: 'metadata')
      end
    end

    describe 'GET /users/saml/idp_sign_out (IdP-initiated logout)' do
      it 'routes to Devise::SamlSessionsController#idp_sign_out' do
        expect(get: '/users/saml/idp_sign_out').to route_to(controller: 'devise/saml_sessions', action: 'idp_sign_out')
        expect(get: idp_destroy_sso_user_session_path).to route_to(controller: 'devise/saml_sessions', action: 'idp_sign_out')
      end
    end

    describe 'POST /users/saml/idp_sign_out (IdP-initiated logout)' do
      it 'routes to Devise::SamlSessionsController#idp_sign_out' do
        expect(post: '/users/saml/idp_sign_out').to route_to(controller: 'devise/saml_sessions', action: 'idp_sign_out')
        expect(post: idp_destroy_sso_user_session_path).to route_to(controller: 'devise/saml_sessions', action: 'idp_sign_out')
      end
    end
  end
end
