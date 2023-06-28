require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class SamlAuthenticatable < Authenticatable
      include DeviseSamlAuthenticatable::SamlConfig
      def valid?
        if params[:SAMLResponse]
          OneLogin::RubySaml::Response.new(
            params[:SAMLResponse],
            response_options,
          )
        else
          false
        end
      end

      def authenticate!
        parse_saml_response
        retrieve_resource unless self.halted?
        unless self.halted?
          @resource.after_saml_authentication(@response.sessionindex)
          success!(@resource)
        end
      end

      # This method should turn off storage whenever CSRF cannot be verified.
      # Any known way on how to let the IdP send the CSRF token along with the SAMLResponse ?
      # Please let me know!
      def store?
        !mapping.to.skip_session_storage.include?(:saml_auth)
      end

      private
      def parse_saml_response
        @response = OneLogin::RubySaml::Response.new(
          params[:SAMLResponse],
          response_options,
        )
        unless @response.is_valid?
          failed_auth("Auth errors: #{@response.errors.join(', ')}")
        end
      end

      def retrieve_resource
        @resource = mapping.to.authenticate_with_saml(@response, params[:RelayState])
        if @resource.nil?
          failed_auth("Resource could not be found")
        end
      end

      def failed_auth(msg)
        DeviseSamlAuthenticatable::Logger.send(msg)
        fail!(:invalid)
        failed_callback.new.handle(@response, self) if Devise.saml_failed_callback
      end

      def failed_callback
        if Devise.saml_failed_callback.respond_to?(:new)
          Devise.saml_failed_callback
        else
          Devise.saml_failed_callback.constantize
        end
      end

      def response_options
        options = {
          settings: saml_config(get_idp_entity_id(params), request),
          allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
        }

        if Devise.saml_validate_in_response_to
          options[:matches_request_id] = request.session[:saml_transaction_id] || "ID_MISSING"
        end

        options
      end
    end
  end
end

Warden::Strategies.add(:saml_authenticatable, Devise::Strategies::SamlAuthenticatable)
