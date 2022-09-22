# Set up a SAML Service Provider

require "onelogin/ruby-saml/version"

attribute_map_resolver = ENV.fetch("ATTRIBUTE_MAP_RESOLVER", "nil")
saml_session_index_key = ENV.fetch('SAML_SESSION_INDEX_KEY', ":session_index")
use_subject_to_authenticate = ENV.fetch('USE_SUBJECT_TO_AUTHENTICATE')
idp_settings_adapter = ENV.fetch('IDP_SETTINGS_ADAPTER', "nil")
idp_entity_id_reader = ENV.fetch('IDP_ENTITY_ID_READER', '"DeviseSamlAuthenticatable::DefaultIdpEntityIdReader"')
saml_failed_callback = ENV.fetch('SAML_FAILED_CALLBACK', "nil")
ruby_saml_version = ENV.fetch("RUBY_SAML_VERSION")

gem 'devise_saml_authenticatable', path: File.expand_path("../../..", __FILE__)
gem 'ruby-saml', ruby_saml_version
gem 'thin'

if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new("3.1")
  gem 'net-smtp', require: false
  gem 'net-imap', require: false
  gem 'net-pop', require: false
end

if Rails::VERSION::MAJOR < 6
  # sqlite3 is hard-coded in Rails < 6 to v1.3.x
  gsub_file 'Gemfile', /^gem 'sqlite3'.*$/, "gem 'sqlite3', '~> 1.3.6'"
end

template File.expand_path('../attribute_map_resolver.rb.erb', __FILE__), 'app/lib/attribute_map_resolver.rb'
template File.expand_path('../idp_settings_adapter.rb.erb', __FILE__), 'app/lib/idp_settings_adapter.rb'

if attribute_map_resolver == "nil"
  create_file 'config/attribute-map.yml', <<-ATTRIBUTES
---
"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress": email
"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name":         name
  ATTRIBUTES
end

create_file('app/lib/our_saml_failed_callback_handler.rb', <<-CALLBACKHANDLER)

class OurSamlFailedCallbackHandler
  def handle(response, strategy)
    strategy.redirect! "http://www.example.com"
  end
end
CALLBACKHANDLER

create_file('app/lib/our_entity_id_reader.rb', <<-READER)

class OurEntityIdReader
  def self.entity_id(params)
    if params[:entity_id]
      params[:entity_id]
    elsif params[:SAMLRequest]
      OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest]).issuer
    elsif params[:SAMLResponse]
      OneLogin::RubySaml::Response.new(params[:SAMLResponse]).issuers.first
    else
      "http://www.cats.com"
    end
  end
end
READER

after_bundle do
  # Configure for our SAML IdP
  generate 'devise:install'
  gsub_file 'config/initializers/devise.rb', /^end$/, <<-CONFIG
  config.secret_key = 'adc7cd73792f5d20055a0ac749ce8cdddb2e0f0d3ea7fe7855eec3d0f81833b9a4ac31d12e05f232d40ae86ca492826a6fc5a65228c6e16752815316e2d5b38d'

  config.saml_default_user_key = :email
  config.saml_session_index_key = #{saml_session_index_key}

  if #{attribute_map_resolver}
    config.saml_attribute_map_resolver = #{attribute_map_resolver}
  end
  config.saml_use_subject = #{use_subject_to_authenticate}
  config.saml_create_user = true
  config.saml_update_user = true
  config.idp_settings_adapter = #{idp_settings_adapter}
  config.idp_entity_id_reader = #{idp_entity_id_reader}
  config.saml_failed_callback = #{saml_failed_callback}

  config.saml_configure do |settings|
    settings.assertion_consumer_service_url = "http://localhost:8020/users/saml/auth"
    settings.issuer = "http://localhost:8020/saml/metadata"
    settings.idp_cert_fingerprint = "9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D"
    settings.name_identifier_format = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
  end
end
  CONFIG
  if Gem::Version.new(ruby_saml_version) >= Gem::Version.new("1.12.0")
    gsub_file 'config/initializers/devise.rb', /^  config\.saml_configure do \|settings\|$/, <<CONFIG
  config.saml_configure do |settings|
    settings.idp_slo_service_url = "http://localhost:8009/saml/logout"
    settings.idp_sso_service_url = "http://localhost:8009/saml/auth"
CONFIG
  else
    gsub_file 'config/initializers/devise.rb', /^  config\.saml_configure do \|settings\|$/, <<CONFIG
  config.saml_configure do |settings|
    settings.idp_slo_target_url = "http://localhost:8009/saml/logout"
    settings.idp_sso_target_url = "http://localhost:8009/saml/auth"
CONFIG
  end

  generate :controller, 'home', 'index'
  insert_into_file('app/controllers/home_controller.rb', after: "class HomeController < ApplicationController\n") {
    <<-AUTHENTICATE
    before_action :authenticate_user!
    AUTHENTICATE
  }
  insert_into_file('app/views/home/index.html.erb', after: /\z/) {
    <<-HOME
<%= current_user.email %> <%= current_user.name %>
<%= form_tag destroy_user_session_path(entity_id: "http://localhost:8020/saml/metadata"), method: :delete do %>
  <%= submit_tag "Log out" %>
<% end %>
    HOME
  }
  route "root to: 'home#index'"

  if Rails::VERSION::MAJOR < 6
    generate :devise, "user", "email:string", "name:string", "session_index:string"
  else
    # devise seems to add `email` by default in Rails 6
    generate :devise, "user", "name:string", "session_index:string"
  end
  gsub_file 'app/models/user.rb', /database_authenticatable.*\n.*/, 'saml_authenticatable'
  route "resources :users, only: [:create]"
  create_file('app/controllers/users_controller.rb', <<-USERS)
class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    User.create!(email: params[:email])
    head 201
  end
end
  USERS

  rake "db:create"
  rake "db:migrate"
  rake "db:create", env: "production"
  rake "db:migrate", env: "production"

  # Remove any specs so that future RSpec runs don't try to also run these
  run 'rm -rf spec'
end

create_file 'public/stylesheets/application.css', ''
