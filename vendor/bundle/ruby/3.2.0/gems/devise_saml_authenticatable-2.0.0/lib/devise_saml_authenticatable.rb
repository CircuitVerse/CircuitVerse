require "devise"

require "devise_saml_authenticatable/version"
require "devise_saml_authenticatable/exception"
require "devise_saml_authenticatable/logger"
require "devise_saml_authenticatable/routes"
require "devise_saml_authenticatable/saml_config"
require "devise_saml_authenticatable/default_attribute_map_resolver"
require "devise_saml_authenticatable/default_idp_entity_id_reader"

begin
  Rails::Engine
rescue
else
  module DeviseSamlAuthenticatable
    class Engine < Rails::Engine
    end
  end
end

# Get saml information from config/saml.yml now
module Devise
  # Allow route customization to avoid collision
  mattr_accessor :saml_route_helper_prefix
  @@saml_route_helper_prefix

  # Allow logging
  mattr_accessor :saml_logger
  @@saml_logger = true

  # Add valid users to database
  # Can accept a Boolean value or a Proc that is called with the model class, the saml_response and auth_value
  # Ex:
  # Devise.saml_create_user = Proc.new do |model_class, saml_response, auth_value|
  #  model_class == Admin
  # end
  mattr_accessor :saml_create_user
  @@saml_create_user = false

  # Update user attributes after login
  # Can accept a Boolean value or a Proc that is called with the model class, the saml_response and auth_value
  # Ex:
  # Devise.saml_update_user = Proc.new do |model_class, saml_response, auth_value|
  #  model_class == User
  # end
  mattr_accessor :saml_update_user
  @@saml_update_user = false

  mattr_accessor :saml_default_user_key
  @@saml_default_user_key

  mattr_accessor :saml_use_subject
  @@saml_use_subject

  # Key used to index sessions for later retrieval
  mattr_accessor :saml_session_index_key
  @@saml_session_index_key ||= :saml_session_index

  # Redirect after signout (redirects to 'users/saml/sign_in' by default)
  mattr_accessor :saml_sign_out_success_url
  @@saml_sign_out_success_url

  # Adapter for multiple IdP support
  mattr_accessor :idp_settings_adapter
  @@idp_settings_adapter

  # Reader that can parse entity id from a SAMLMessage
  mattr_accessor :idp_entity_id_reader
  @@idp_entity_id_reader ||= "::DeviseSamlAuthenticatable::DefaultIdpEntityIdReader"

  # Implements a #handle method that takes the response and strategy as an argument
  mattr_accessor :saml_failed_callback
  @@saml_failed_callback

  # lambda that generates the RelayState param for the SAML AuthRequest, takes request
  # from SamlSessionsController#new action as an argument
  mattr_accessor :saml_relay_state
  @@saml_relay_state

  # Validate that the InResponseTo header in SAML responses matches the ID of the request.
  mattr_accessor :saml_validate_in_response_to
  @@saml_validate_in_response_to = false

  # Instead of storing the attribute_map in attribute-map.yml, store it in the database, or set it programatically
  mattr_accessor :saml_attribute_map_resolver
  @@saml_attribute_map_resolver ||= "::DeviseSamlAuthenticatable::DefaultAttributeMapResolver"

  # Implements a #validate method that takes the retrieved resource and response right after retrieval,
  # and returns true if it's valid.  False will cause authentication to fail.
  # Only one of saml_resource_validator and saml_resource_validator_hook may be used.
  mattr_accessor :saml_resource_validator
  @@saml_resource_validator

  # Proc that determines whether a technically correct SAML response is valid per some custom logic.
  # Receives the user object (or nil, if no match was found), decorated saml_response and
  # auth_value, inspects the combination for acceptability of login (or create+login, if enabled),
  # and returns true if it's valid.  False will cause authentication to fail.
  mattr_accessor :saml_resource_validator_hook
  @@saml_resource_validator_hook

  # Custom value for ruby-saml allowed_clock_drift
  mattr_accessor :allowed_clock_drift_in_seconds
  @@allowed_clock_drift_in_seconds

  mattr_accessor :saml_config
  @@saml_config = OneLogin::RubySaml::Settings.new
  def self.saml_configure
    yield saml_config
  end

  # Default update resource hook. Updates each attribute on the model that is mapped, updates the
  # saml_default_user_key if saml_use_subject is true and saves the user model.
  # See saml_update_resource_hook for more information.
  mattr_reader :saml_default_update_resource_hook
  @@saml_default_update_resource_hook = Proc.new do |user, saml_response, auth_value|
    saml_response.attributes.resource_keys.each do |key|
      user.send "#{key}=", saml_response.attribute_value_by_resource_key(key)
    end

    if (Devise.saml_use_subject)
      user.send "#{Devise.saml_default_user_key}=", auth_value
    end

    user.save!
  end

  # Proc that is called if Devise.saml_update_user and/or Devise.saml_create_user are true.
  # Receives the user object, saml_response and auth_value, and defines how the object's values are
  # updated with regards to the SAML response. See saml_default_update_resource_hook for an example.
  mattr_accessor :saml_update_resource_hook
  @@saml_update_resource_hook = @@saml_default_update_resource_hook

  # Default resource locator. Uses saml_default_user_key and auth_value to resolve user.
  # See saml_resource_locator for more information.
  mattr_reader :saml_default_resource_locator
  @@saml_default_resource_locator = Proc.new do |model, saml_response, auth_value|
    model.find_by(Devise.saml_default_user_key => auth_value)
  end

  # Proc that is called to resolve the saml_response and auth_value into the correct user object.
  # Receives a copy of the ActiveRecord::Model, saml_response and auth_value. Is expected to return
  # one instance of the provided model that is the matched account, or nil if none exists.
  # See saml_default_resource_locator above for an example.
  mattr_accessor :saml_resource_locator
  @@saml_resource_locator = @@saml_default_resource_locator

  # Proc that is called to resolve the name identifier to use in a LogoutRequest for the current user.
  # Receives the logged-in user.
  # Is expected to return the identifier the IdP understands for this user, e.g. email address or username.
  mattr_accessor :saml_name_identifier_retriever
  @@saml_name_identifier_retriever = Proc.new do |current_user|
    current_user.public_send(Devise.saml_default_user_key)
  end
end

# Add saml_authenticatable strategy to defaults.
#
Devise.add_module(:saml_authenticatable,
                  :route => :saml_authenticatable,
                  :strategy   => true,
                  :controller => :saml_sessions,
                  :model  => 'devise_saml_authenticatable/model')
