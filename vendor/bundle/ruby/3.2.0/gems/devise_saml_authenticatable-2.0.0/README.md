[![Build Status](https://github.com/apokalipto/devise_saml_authenticatable/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/apokalipto/devise_saml_authenticatable/actions/workflows/ci.yml)
# DeviseSamlAuthenticatable

Devise Saml Authenticatable is a Single-Sign-On authentication strategy for devise that relies on SAML.
It uses [ruby-saml][] to handle all SAML-related stuff.

> [!WARNING]
> The master branch now represents v2.x of this gem, which is still unreleased.
> See [the 1.x branch README](https://github.com/apokalipto/devise_saml_authenticatable/tree/refs/heads/1.x-maintenance?tab=readme-ov-file) for details about that version.

## Installation

Add this gem to your application's Gemfile:

    gem "devise_saml_authenticatable"

And then execute:

    $ bundle

## Usage

Follow the [normal devise installation process](https://github.com/plataformatec/devise/tree/master#getting-started). The controller filters and helpers are unchanged from normal devise usage.

### Configuring Models

In `app/models/<YOUR_MODEL>.rb` set the `:saml_authenticatable` strategy.

In the example the model is `user.rb`:

```ruby
  class User < ActiveRecord::Base
    ...
    devise :saml_authenticatable, :trackable
    ...
  end
```

### Configuring routes

In `config/routes.rb` add `devise_for` to set up helper methods and routes:

```ruby
devise_for :users
```

The named routes can be customized in the initializer config file.

### Configuring the IdP

An extra step in SAML SSO setup is adding your application to your identity provider. The required setup is specific to each IdP, but we have some examples in [our wiki](https://github.com/apokalipto/devise_saml_authenticatable/wiki). You'll need to tell your IdP how to send requests and responses to your application.

- Creating a new session: `/users/saml/auth`
    - IdPs may call this the "consumer," "recipient," "destination," or even "single sign-on." This is where they send a SAML response for an authenticated user.
- Metadata: `/users/saml/metadata`
    - IdPs may call this the "audience."
- Single Logout: `/users/saml/idp_sign_out`
    - if desired, you can ask the IdP to send a Logout request to this endpoint to sign the user out of your application when they sign out of the IdP itself.

Your IdP should give you some information you need to configure in [ruby-saml](https://github.com/onelogin/ruby-saml), as in the next section:

- Issuer (`idp_entity_id`)
- SSO endpoint (`idp_sso_service_url`)
- SLO endpoint (`idp_slo_service_url`)
- Certificate fingerprint (`idp_cert_fingerprint`) and algorithm (`idp_cert_fingerprint_algorithm`)
    - Or the certificate itself (`idp_cert`)

### Configuring handling of IdP requests and responses

In `config/initializers/devise.rb`:

```ruby
  Devise.setup do |config|
    ...
    # ==> Configuration for :saml_authenticatable

    # Create user if the user does not exist. (Default is false)
    # Can also accept a proc, for ex:
    # Devise.saml_create_user = Proc.new do |model_class, saml_response, auth_value|
    #  model_class == Admin
    # end
    config.saml_create_user = true

    # Update the attributes of the user after a successful login. (Default is false)
    # Can also accept a proc, for ex:
    # Devise.saml_update_user = Proc.new do |model_class, saml_response, auth_value|
    #  model_class == Admin
    # end
    config.saml_update_user = true

    # Lambda that is called if Devise.saml_update_user and/or Devise.saml_create_user are true.
    # Receives the model object, saml_response and auth_value, and defines how the object's values are
    # updated with regards to the SAML response.
    # config.saml_update_resource_hook = -> (user, saml_response, auth_value) {
    #   saml_response.attributes.resource_keys.each do |key|
    #     user.send "#{key}=", saml_response.attribute_value_by_resource_key(key)
    #   end
    #
    #   if (Devise.saml_use_subject)
    #     user.send "#{Devise.saml_default_user_key}=", auth_value
    #   end
    #
    #   user.save!
    # }

    # Lambda that is called to resolve the saml_response and auth_value into the correct user object.
    # Receives a copy of the ActiveRecord::Model, saml_response and auth_value. Is expected to return
    # one instance of the provided model that is the matched account, or nil if none exists.
    # config.saml_resource_locator = -> (model, saml_response, auth_value) {
    #   model.find_by(Devise.saml_default_user_key => auth_value)
    # }


    # Set the default user key. The user will be looked up by this key. Make
    # sure that the Authentication Response includes the attribute.
    config.saml_default_user_key = :email

    # Optional. This stores the session index defined by the IDP during login.
    # If provided it will be used to facilitate an IDP initiated logout request.
    config.saml_session_index_key = :saml_session_index

    # You can set this value to use Subject or SAML assertion as info to which email will be compared.
    # If you don't set it then email will be extracted from SAML assertion attributes.
    config.saml_use_subject = true

    # You can implement IdP settings with the options to support multiple IdPs and use the request object by setting this value to the name of a class that implements a ::settings method
    # which takes an IdP entity id and a request object as arguments and returns a hash of idp settings for the corresponding IdP.
    # config.idp_settings_adapter = "MyIdPSettingsAdapter"

    # You provide you own method to find the idp_entity_id in a SAML message in the case of multiple IdPs
    # by setting this to the name of a custom reader class, or use the default.
    # config.idp_entity_id_reader = "DeviseSamlAuthenticatable::DefaultIdpEntityIdReader"

    # You can set the name of a class that takes the response for a failed SAML request and the strategy,
    # and implements a #handle method. This method can then redirect the user, return error messages, etc.
    # config.saml_failed_callback = "MySamlFailedCallbacksHandler"

    # You can customize the named routes generated in case of named route collisions with
    # other Devise modules or libraries. Set the saml_route_helper_prefix to a string that will
    # be appended to the named route.
    # If saml_route_helper_prefix = 'saml' then the new_user_session route becomes new_saml_user_session
    # config.saml_route_helper_prefix = 'saml'

    # You can add allowance for clock drift between the sp and idp.
    # This is a time in seconds.
    # config.allowed_clock_drift_in_seconds = 0

    # In SAML responses, validate that the identity provider has included an InResponseTo
    # header that matches the ID of the SAML request. (Default is false)
    # config.saml_validate_in_response_to = false

    # Configure with your SAML settings (see ruby-saml's README for more information: https://github.com/onelogin/ruby-saml).
    config.saml_configure do |settings|
      settings.assertion_consumer_service_url     = "http://localhost:3000/users/saml/auth"
      settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
      settings.name_identifier_format             = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
      settings.sp_entity_id                       = "http://localhost:3000/saml/metadata"
      settings.authn_context                      = ""
      settings.idp_slo_service_url                = "http://localhost/simplesaml/www/saml2/idp/SingleLogoutService.php"
      settings.idp_sso_service_url                = "http://localhost/simplesaml/www/saml2/idp/SSOService.php"
      settings.idp_cert_fingerprint               = "00:A1:2B:3C:44:55:6F:A7:88:CC:DD:EE:22:33:44:55:D6:77:8F:99"
      settings.idp_cert_fingerprint_algorithm     = "http://www.w3.org/2000/09/xmldsig#sha1"
    end
  end
```

#### Attributes

There are two ways to map SAML attributes to User attributes:

- [initializer](#attribute-map-initializer)
- [config file](#attribute-map-config-file)

The attribute mappings are very dependent on the way the IdP encodes the attributes.
In these examples the attributes are given in URN style.
Other IdPs might provide them as OID's, or by other means.

You are now ready to test it against an IdP.

When the user visits `/users/saml/sign_in` they will be redirected to the login page of the IdP.

Upon successful login the user is redirected to the Devise `user_root_path`.

##### Attribute map config file

Create a YAML file (`config/attribute-map.yml`) that maps SAML attributes with your model's fields:

```yaml
  # attribute-map.yml

  "urn:mace:dir:attribute-def:uid": "user_name"
  "urn:mace:dir:attribute-def:email": "email"
  "urn:mace:dir:attribute-def:name": "last_name"
  "urn:mace:dir:attribute-def:givenName": "name"
```

##### Attribute map initializer

In `config/initializers/devise.rb` (see above), add an attribute map resolver.
The resolver gets the [SAML response from the IdP](https://github.com/onelogin/ruby-saml/blob/master/lib/onelogin/ruby-saml/response.rb) so it can decide which attribute map to load.
If you only have one IdP, you can use the config file above, or just return a single hash.

```ruby
  # config/initializers/devise.rb
  Devise.setup do |config|
    ...
    # ==> Configuration for :saml_authenticatable

    config.saml_attribute_map_resolver = "MyAttributeMapResolver"
  end
```

```ruby
  # app/lib/my_attribute_map_resolver
  class MyAttributeMapResolver < DeviseSamlAuthenticatable::DefaultAttributeMapResolver
    def attribute_map
      issuer = saml_response.issuers.first
      case issuer
      when "idp_entity_id"
        {
          "urn:mace:dir:attribute-def:uid" => "user_name",
          "urn:mace:dir:attribute-def:email" => "email",
          "urn:mace:dir:attribute-def:name" => "last_name",
          "urn:mace:dir:attribute-def:givenName" => "name",
        }
      end
    end
  end
```

If you are mapping authorisation *groups* or any other array of values as some providers render (ie: Okta), be aware of [ruby-saml's `single_value_compatibility`](https://github.com/SAML-Toolkits/ruby-saml#retrieving-attributes).


## IdP Settings Adapter

Implementing a custom settings adapter allows you to support multiple Identity Providers, and dynamic application domains with the request object.

You can implement an adapter class with a `#settings` method. It must take two arguments (idp_entity_id, request) and return a hash of settings for the corresponding IdP. The `config.idp_settings_adapter` then must be set to point to your adapter in `config/initializers/devise.rb`. The implementation of the adapter is up to you. A simple example may look like this:

```ruby
class IdPSettingsAdapter
  def self.settings(idp_entity_id, request)
    case idp_entity_id
    when "http://www.example_idp_entity_id.com"
      {
        assertion_consumer_service_url: "#{request.protocol}#{request.host_with_port}/users/saml/auth",
        assertion_consumer_service_binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
        name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:transient",
        sp_entity_id: "#{request.protocol}#{request.host_with_port}/saml/metadata",
        idp_entity_id: "http://www.example_idp_entity_id.com",
        authn_context: "",
        idp_slo_service_url: "http://example_idp_slo_service_url.com",
        idp_sso_service_url: "http://example_idp_sso_service_url.com",
        idp_cert: "example_idp_cert"
      }
    when "http://www.another_idp_entity_id.biz"
      {
        assertion_consumer_service_url: "http://localhost:3000/users/saml/auth",
        assertion_consumer_service_binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
        name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:transient",
        sp_entity_id: "http://localhost:3000/saml/metadata",
        idp_entity_id: "http://www.another_idp_entity_id.biz",
        authn_context: "",
        idp_slo_service_url: "http://another_idp_slo_service_url.com",
        idp_sso_service_url: "http://another_idp_sso_service_url.com",
        idp_cert: "another_idp_cert"
      }
    else
      {}
    end
  end
end
```
Settings specified in the adapter will override settings in `config/initializers/devise.rb`. This is useful for establishing common settings or defaults across all IdPs.

Detecting the entity ID passed to the `settings` method is done by `config.idp_entity_id_reader`.

By default this will find the `Issuer` in the SAML request.

You can support more use cases by writing your own and implementing the `.entity_id` method.

If you use encrypted assertions, your entity ID reader will need to understand how to decrypt the response from each of the possible IdPs.

## Identity Provider

If you don't have an identity provider and you would like to test the authentication against your app, there are some options:

1. Use [ruby-saml-idp](https://github.com/lawrencepit/ruby-saml-idp). You can add your own logic to your IdP, or you can also set it up as a dummy IdP that always sends a valid authentication response to your app.
2. Use an online service that can act as an IdP. OneLogin, Salesforce, Okta and some others provide you with this functionality.
3. Install your own IdP.

There are numerous IdPs that support SAML 2.0, there are propietary (like Microsoft ADFS 2.0 or Ping federate) and there are also open source solutions like Shibboleth and [SimpleSAMLphp].

[SimpleSAMLphp] was my choice for development since it is a production-ready SAML solution, that is also really easy to install, configure and use.

[SimpleSAMLphp]: http://simplesamlphp.org/

## Logout

Logout support is included by immediately terminating the local session and then redirecting to the IdP.

## Logout Request

Logout requests from the IDP are supported by the `idp_sign_out` endpoint.  Directing logout requests to `users/saml/idp_sign_out` will log out the respective user by invalidating their current sessions.

To disable this feature, set `saml_session_index_key` to `nil`.

## Signing and Encrypting Authentication Requests and Assertions

ruby-saml 1.0.0 supports signature and decrypt. The only requirement is to set the public certificate and the private key. For more information, see [the ruby-saml documentation](https://github.com/onelogin/ruby-saml#signing).

If you have multiple IdPs, the certificate and private key must be in the shared settings in `config/initializers/devise.rb`.

## Thanks

The continued maintenance of this gem could not have been possible without the hard work of [Adam Stegman](https://github.com/adamstegman) and [Mitch Lindsay](https://github.com/mitch-lindsay). Thank you guys for keeping this project alive.

Thanks to all other contributors that have also helped us make this software better.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Run the tests (`bundle exec rspec`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

[ruby-saml]: https://github.com/onelogin/ruby-saml
