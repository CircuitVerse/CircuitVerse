
class Users::SamlSessionsController < Devise::SamlSessionsController
    skip_before_action :verify_authenticity_token, raise: false
    after_action :store_winning_strategy, only: :create
  
    def new
      request = OneLogin::RubySaml::Authrequest.new
      action = request.create(saml_settings)
      redirect_to action
    end
  
    def metadata
      meta = OneLogin::RubySaml::Metadata.new
      render xml: meta.generate(saml_settings)
    end
  
    def create
      response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: saml_settings)
    
      if response.is_valid?
        @user = User.find_or_create_by(email: response.nameid) do |user|
          user.password = Devise.friendly_token[0, 20] # Set a default password
        end
        sign_in @user
        # sign_in_and_redirect @user, event: :authentication
      else
        redirect_to new_user_session_path, alert: 'Invalid SAML response'
      end
    end
  
    private
    def saml_settings
        settings = OneLogin::RubySaml::Settings.new
      
        settings.assertion_consumer_service_url     = Devise.saml_config.assertion_consumer_service_url
        settings.assertion_consumer_service_binding = Devise.saml_config.assertion_consumer_service_binding
        settings.name_identifier_format             = Devise.saml_config.name_identifier_format
        settings.issuer                             = Devise.saml_config.issuer
        settings.authn_context                      = Devise.saml_config.authn_context
        settings.idp_slo_target_url                 = Devise.saml_config.idp_slo_target_url
        settings.idp_sso_target_url                 = Devise.saml_config.idp_sso_target_url
        settings.idp_cert_fingerprint               = Devise.saml_config.idp_cert_fingerprint
        settings.idp_cert_fingerprint_algorithm     = Devise.saml_config.idp_cert_fingerprint_algorithm
      
        settings
      end
      def store_winning_strategy
        warden.session(:user)[:strategy] = warden.winning_strategies[:user].class.name.demodulize.underscore.to_sym
      end
  end