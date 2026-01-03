# Set up a SAML IdP

@email_address_attribute_key = ENV.fetch("EMAIL_ADDRESS_ATTRIBUTE_KEY", "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress")
@name_attribute_key = ENV.fetch("NAME_ATTRIBUTE_KEY", "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name")
@include_subject_in_attributes = ENV.fetch('INCLUDE_SUBJECT_IN_ATTRIBUTES')
@valid_destination = ENV.fetch('VALID_DESTINATION', "true")

gem 'stub_saml_idp'
gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false

route "get '/saml/auth' => 'saml_idp#new'"
route "post '/saml/auth' => 'saml_idp#create'"
route "get '/saml/logout' => 'saml_idp#logout'"
route "get '/saml/sp_sign_out' => 'saml_idp#sp_sign_out'"

template File.expand_path('../saml_idp_controller.rb.erb', __FILE__), 'app/controllers/saml_idp_controller.rb'

copy_file File.expand_path('../saml_idp-saml_slo_post.html.erb', __FILE__), 'app/views/saml_idp/saml_slo_post.html.erb'
create_file 'public/stylesheets/application.css', ''

gsub_file 'config/application.rb', /end[\n\w]*end$/, <<-CONFIG
    config.slo_sp_url = "http://localhost:8020/users/saml/idp_sign_out"
  end
end
CONFIG
