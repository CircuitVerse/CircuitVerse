# Ruby SAML
[![Build Status](https://github.com/onelogin/ruby-saml/actions/workflows/test.yml/badge.svg?query=branch%3Amaster)](https://github.com/onelogin/ruby-saml/actions/workflows/test.yml?query=branch%3Amaster)
[![Coverage Status](https://coveralls.io/repos/onelogin/ruby-saml/badge.svg?branch=master)](https://coveralls.io/r/onelogin/ruby-saml?branch=master)

Ruby SAML minor and tiny versions may introduce breaking changes. Please read
[UPGRADING.md](UPGRADING.md) for guidance on upgrading to new Ruby SAML versions.

## Overview

The Ruby SAML library is for implementing the client side of a SAML authorization,
i.e. it provides a means for managing authorization initialization and confirmation
requests from identity providers.

SAML authorization is a two step process and you are expected to implement support for both.

We created a demo project for Rails 4 that uses the latest version of this library:
[ruby-saml-example](https://github.com/onelogin/ruby-saml-example)

### Supported Ruby Versions

The following Ruby versions are covered by CI testing:

* 2.1.x
* 2.2.x
* 2.3.x
* 2.4.x
* 2.5.x
* 2.6.x
* 2.7.x
* 3.0.x
* JRuby 9.1.x
* JRuby 9.2.x
* TruffleRuby (latest)

In addition, the following may work but are untested:

* 1.8.7
* 1.9.x
* 2.0.x
* JRuby 1.7.x
* JRuby 9.0.x

## Adding Features, Pull Requests

* Fork the repository
* Make your feature addition or bug fix
* Add tests for your new features. This is important so we don't break any features in a future version unintentionally.
* Ensure all tests pass by running `bundle exec rake test`.
* Do not change rakefile, version, or history.
* Open a pull request, following [this template](https://gist.github.com/Lordnibbler/11002759).

## Security Guidelines

If you believe you have discovered a security vulnerability in this gem, please report it
at https://www.onelogin.com/security with a description. We follow responsible disclosure
guidelines, and will work with you to quickly find a resolution.

### Security Warning

Some tools may incorrectly report ruby-saml is a potential security vulnerability.
ruby-saml depends on Nokogiri, and it's possible to use Nokogiri in a dangerous way
(by enabling its DTDLOAD option and disabling its NONET option).
This dangerous Nokogiri configuration, which is sometimes used by other components,
can create an XML External Entity (XXE) vulnerability if the XML data is not trusted.
However, ruby-saml never enables this dangerous Nokogiri configuration;
ruby-saml never enables DTDLOAD, and it never disables NONET.

The OneLogin::RubySaml::IdpMetadataParser class does not validate in any way the URL
that is introduced in order to be parsed.

Usually the same administrator that handles the Service Provider also sets the URL to
the IdP, which should be a trusted resource.

But there are other scenarios, like a SAAS app where the administrator of the app
delegates this functionality to other users. In this case, extra precaution should
be taken in order to validate such URL inputs and avoid attacks like SSRF.

## Getting Started

In order to use Ruby SAML you will need to install the gem (either manually or using Bundler),
and require the library in your Ruby application:

Using `Gemfile`

```ruby
# latest stable
gem 'ruby-saml', '~> 1.11.0'

# or track master for bleeding-edge
gem 'ruby-saml', :github => 'onelogin/ruby-saml'
```

Using RubyGems

```sh
gem install ruby-saml
```

You may require the entire Ruby SAML gem:

```ruby
require 'onelogin/ruby-saml'
```

or just the required components individually:

```ruby
require 'onelogin/ruby-saml/authrequest'
```

### Installation on Ruby 1.8.7

This gem uses Nokogiri as a dependency, which dropped support for Ruby 1.8.x in Nokogiri 1.6.
When installing this gem on Ruby 1.8.7, you will need to make sure a version of Nokogiri
prior to 1.6 is installed or specified if it hasn't been already.

Using `Gemfile`

```ruby
gem 'nokogiri', '~> 1.5.10'
```

Using RubyGems

```sh
gem install nokogiri --version '~> 1.5.10'
````

### Configuring Logging

When troubleshooting SAML integration issues, you will find it extremely helpful to examine the
output of this gem's business logic. By default, log messages are emitted to RAILS_DEFAULT_LOGGER
when the gem is used in a Rails context, and to STDOUT when the gem is used outside of Rails.

To override the default behavior and control the destination of log messages, provide
a ruby Logger object to the gem's logging singleton:

```ruby
OneLogin::RubySaml::Logging.logger = Logger.new('/var/log/ruby-saml.log')
```

## The Initialization Phase

This is the first request you will get from the identity provider. It will hit your application
at a specific URL that you've announced as your SAML initialization point. The response to
this initialization is a redirect back to the identity provider, which can look something
like this (ignore the saml_settings method call for now):

```ruby
def init
  request = OneLogin::RubySaml::Authrequest.new
  redirect_to(request.create(saml_settings))
end
```

If the SP knows who should be authenticated in the IdP, then can provide that info as follows:

```ruby
def init
  request = OneLogin::RubySaml::Authrequest.new
  saml_settings.name_identifier_value_requested = "testuser@example.com"
  saml_settings.name_identifier_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  redirect_to(request.create(saml_settings))
end
```

Once you've redirected back to the identity provider, it will ensure that the user has been
authorized and redirect back to your application for final consumption.
This can look something like this (the `authorize_success` and `authorize_failure`
methods are specific to your application):

```ruby
def consume
  response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => saml_settings)

  # We validate the SAML Response and check if the user already exists in the system
  if response.is_valid?
     # authorize_success, log the user
     session[:userid] = response.nameid
     session[:attributes] = response.attributes
  else
    authorize_failure  # This method shows an error message
    # List of errors is available in response.errors array
  end
end
```

In the above there are a few assumptions, one being that `response.nameid` is an email address.
This is all handled with how you specify the settings that are in play via the `saml_settings` method.
That could be implemented along the lines of this:

```
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
response.settings = saml_settings
```

If the assertion of the SAMLResponse is not encrypted, you can initialize the Response
without the `:settings` parameter and set it later. If the SAMLResponse contains an encrypted
assertion, you need to provide the settings in the initialize method in order to obtain the
decrypted assertion, using the service provider private key in order to decrypt.
If you don't know what expect, always use the former (set the settings on initialize).

```ruby
def saml_settings
  settings = OneLogin::RubySaml::Settings.new

  settings.assertion_consumer_service_url = "http://#{request.host}/saml/consume"
  settings.sp_entity_id                   = "http://#{request.host}/saml/metadata"
  settings.idp_entity_id                  = "https://app.onelogin.com/saml/metadata/#{OneLoginAppId}"
  settings.idp_sso_service_url            = "https://app.onelogin.com/trust/saml2/http-post/sso/#{OneLoginAppId}"
  settings.idp_sso_service_binding        = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" # or :post, :redirect
  settings.idp_slo_service_url            = "https://app.onelogin.com/trust/saml2/http-redirect/slo/#{OneLoginAppId}"
  settings.idp_slo_service_binding        = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" # or :post, :redirect
  settings.idp_cert_fingerprint           = OneLoginAppCertFingerPrint
  settings.idp_cert_fingerprint_algorithm = "http://www.w3.org/2000/09/xmldsig#sha1"
  settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

  # Optional for most SAML IdPs
  settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
  # or as an array
  settings.authn_context = [
    "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport",
    "urn:oasis:names:tc:SAML:2.0:ac:classes:Password"
  ]

  # Optional bindings (defaults to Redirect for logout POST for ACS)
  settings.single_logout_service_binding      = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" # or :post, :redirect
  settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" # or :post, :redirect

  settings
end
```

The use of settings.issuer is deprecated in favour of settings.sp_entity_id since version 1.11.0

Some assertion validations can be skipped by passing parameters to `OneLogin::RubySaml::Response.new()`.
For example, you can skip the `AuthnStatement`, `Conditions`, `Recipient`, or the `SubjectConfirmation`
validations by initializing the response with different options:

```ruby
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], {skip_authnstatement: true}) # skips AuthnStatement
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], {skip_conditions: true}) # skips conditions
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], {skip_subject_confirmation: true}) # skips subject confirmation
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], {skip_recipient_check: true}) # doesn't skip subject confirmation, but skips the recipient check which is a sub check of the subject_confirmation check
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], {skip_audience: true}) # skips audience check
```

All that's left is to wrap everything in a controller and reference it in the initialization and
consumption URLs in OneLogin. A full controller example could look like this:

```ruby
# This controller expects you to use the URLs /saml/init and /saml/consume in your OneLogin application.
class SamlController < ApplicationController
  def init
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def consume
    response          = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
    response.settings = saml_settings

    # We validate the SAML Response and check if the user already exists in the system
    if response.is_valid?
       # authorize_success, log the user
       session[:userid] = response.nameid
       session[:attributes] = response.attributes
    else
      authorize_failure  # This method shows an error message
      # List of errors is available in response.errors array
    end
  end

  private

  def saml_settings
    settings = OneLogin::RubySaml::Settings.new

    settings.assertion_consumer_service_url = "http://#{request.host}/saml/consume"
    settings.sp_entity_id                   = "http://#{request.host}/saml/metadata"
    settings.idp_sso_service_url             = "https://app.onelogin.com/saml/signon/#{OneLoginAppId}"
    settings.idp_cert_fingerprint           = OneLoginAppCertFingerPrint
    settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    # Optional for most SAML IdPs
    settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

    # Optional. Describe according to IdP specification (if supported) which attributes the SP desires to receive in SAMLResponse.
    settings.attributes_index = 5
    # Optional. Describe an attribute consuming service for support of additional attributes.
    settings.attribute_consuming_service.configure do
      service_name "Service"
      service_index 5
      add_attribute :name => "Name", :name_format => "Name Format", :friendly_name => "Friendly Name"
    end

    settings
  end
end
```

## Signature Validation

Ruby SAML allows different ways to validate the signature of the SAMLResponse:
- You can provide the IdP X.509 public certificate at the `idp_cert` setting.
- You can provide the IdP X.509 public certificate in fingerprint format using the
 `idp_cert_fingerprint` setting parameter and additionally the `idp_cert_fingerprint_algorithm` parameter.

When validating the signature of redirect binding, the fingerprint is useless and the certificate
of the IdP is required in order to execute the validation. You can pass the option
`:relax_signature_validation` to `SloLogoutrequest` and `Logoutresponse` if want to avoid signature
validation if no certificate of the IdP is provided.

In production also we highly recommend to register on the settings the IdP certificate instead
of using the fingerprint method. The fingerprint, is a hash, so at the end is open to a collision
attack that can end on a signature validation bypass. Other SAML toolkits deprecated that mechanism,
we maintain it for compatibility and also to be used on test environment.

## Handling Multiple IdP Certificates

If the IdP metadata XML includes multiple certificates, you may specify the `idp_cert_multi`
parameter. When used, the `idp_cert` and `idp_cert_fingerprint` parameters are ignored.
This is useful in the following scenarios:

* The IdP uses different certificates for signing versus encryption.
* The IdP is undergoing a key rollover and is publishing the old and new certificates in parallel.

The `idp_cert_multi` must be a `Hash` as follows. The `:signing` and `:encryption` arrays below,
add the IdP X.509 public certificates which were published in the IdP metadata.

```ruby
{
  :signing => [],
  :encryption => []
}
```

## Metadata Based Configuration

The method above requires a little extra work to manually specify attributes about both the IdP and your SP application.
There's an easier method: use a metadata exchange. Metadata is an XML file that defines the capabilities of both the IdP
and the SP application. It also contains the X.509 public key certificates which add to the trusted relationship.
The IdP administrator can also configure custom settings for an SP based on the metadata.

Using `IdpMetadataParser#parse_remote`, the IdP metadata will be added to the settings.

```ruby
def saml_settings

  idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
  # Returns OneLogin::RubySaml::Settings pre-populated with IdP metadata
  settings = idp_metadata_parser.parse_remote("https://example.com/auth/saml2/idp/metadata")

  settings.assertion_consumer_service_url = "http://#{request.host}/saml/consume"
  settings.sp_entity_id                   = "http://#{request.host}/saml/metadata"
  settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  # Optional for most SAML IdPs
  settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

  settings
end
```

The following attributes are set:
  * idp_entity_id
  * name_identifier_format
  * idp_sso_service_url
  * idp_slo_service_url
  * idp_attribute_names
  * idp_cert
  * idp_cert_fingerprint
  * idp_cert_multi

### Retrieve one Entity Descriptor when many exist in Metadata

If the Metadata contains several entities, the relevant Entity
Descriptor can be specified when retrieving the settings from the
IdpMetadataParser by its Entity Id value:

```ruby
  validate_cert = true
  settings = idp_metadata_parser.parse_remote(
               "https://example.com/auth/saml2/idp/metadata",
               validate_cert,
               entity_id: "http//example.com/target/entity"
             )
```

### Parsing Metadata into an Hash

The `OneLogin::RubySaml::IdpMetadataParser` also provides the methods `#parse_to_hash` and `#parse_remote_to_hash`.
Those return an Hash instead of a `Settings` object, which may be useful for configuring
[omniauth-saml](https://github.com/omniauth/omniauth-saml), for instance.

## Retrieving Attributes

If you are using `saml:AttributeStatement` to transfer data like the username, you can access all the attributes through `response.attributes`. It contains all the `saml:AttributeStatement`s with its 'Name' as an indifferent key and one or more `saml:AttributeValue`s as values. The value returned depends on the value of the
`single_value_compatibility` (when activated, only the first value is returned)

```ruby
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
response.settings = saml_settings

response.attributes[:username]
```

Imagine this `saml:AttributeStatement`

```xml
  <saml:AttributeStatement>
    <saml:Attribute Name="uid">
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">demo</saml:AttributeValue>
    </saml:Attribute>
    <saml:Attribute Name="another_value">
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">value1</saml:AttributeValue>
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">value2</saml:AttributeValue>
    </saml:Attribute>
    <saml:Attribute Name="role">
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">role1</saml:AttributeValue>
    </saml:Attribute>
    <saml:Attribute Name="role">
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">role2</saml:AttributeValue>
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">role3</saml:AttributeValue>
    </saml:Attribute>
    <saml:Attribute Name="attribute_with_nil_value">
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/>
    </saml:Attribute>
    <saml:Attribute Name="attribute_with_nils_and_empty_strings">
      <saml:AttributeValue/>
      <saml:AttributeValue>valuePresent</saml:AttributeValue>
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/>
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="1"/>
    </saml:Attribute>
    <saml:Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname">
      <saml:AttributeValue>usersName</saml:AttributeValue>
    </saml:Attribute>
  </saml:AttributeStatement>
```

```ruby
pp(response.attributes)   # is an OneLogin::RubySaml::Attributes object
# => @attributes=
  {"uid"=>["demo"],
   "another_value"=>["value1", "value2"],
   "role"=>["role1", "role2", "role3"],
   "attribute_with_nil_value"=>[nil],
   "attribute_with_nils_and_empty_strings"=>["", "valuePresent", nil, nil]
   "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"=>["usersName"]}>

# Active single_value_compatibility
OneLogin::RubySaml::Attributes.single_value_compatibility = true

pp(response.attributes[:uid])
# => "demo"

pp(response.attributes[:role])
# => "role1"

pp(response.attributes.single(:role))
# => "role1"

pp(response.attributes.multi(:role))
# => ["role1", "role2", "role3"]

pp(response.attributes.fetch(:role))
# => "role1"

pp(response.attributes[:attribute_with_nil_value])
# => nil

pp(response.attributes[:attribute_with_nils_and_empty_strings])
# => ""

pp(response.attributes[:not_exists])
# => nil

pp(response.attributes.single(:not_exists))
# => nil

pp(response.attributes.multi(:not_exists))
# => nil

pp(response.attributes.fetch(/givenname/))
# => "usersName"

# Deprecated single_value_compatibility
OneLogin::RubySaml::Attributes.single_value_compatibility = false

pp(response.attributes[:uid])
# => ["demo"]

pp(response.attributes[:role])
# => ["role1", "role2", "role3"]

pp(response.attributes.single(:role))
# => "role1"

pp(response.attributes.multi(:role))
# => ["role1", "role2", "role3"]

pp(response.attributes.fetch(:role))
# => ["role1", "role2", "role3"]

pp(response.attributes[:attribute_with_nil_value])
# => [nil]

pp(response.attributes[:attribute_with_nils_and_empty_strings])
# => ["", "valuePresent", nil, nil]

pp(response.attributes[:not_exists])
# => nil

pp(response.attributes.single(:not_exists))
# => nil

pp(response.attributes.multi(:not_exists))
# => nil

pp(response.attributes.fetch(/givenname/))
# => ["usersName"]
```

The `saml:AuthnContextClassRef` of the AuthNRequest can be provided by `settings.authn_context`; possible values are described at [SAMLAuthnCxt]. The comparison method can be set using `settings.authn_context_comparison` parameter. Possible values include: 'exact', 'better', 'maximum' and 'minimum' (default value is 'exact').
To add a `saml:AuthnContextDeclRef`, define `settings.authn_context_decl_ref`.

In a SP-initiated flow, the SP can indicate to the IdP the subject that should be authenticated. This is done by defining the `settings.name_identifier_value_requested` before
building the authrequest object.

## Service Provider Metadata

To form a trusted pair relationship with the IdP, the SP (you) need to provide metadata XML
to the IdP for various good reasons. (Caching, certificate lookups, relaying party permissions, etc)

The class `OneLogin::RubySaml::Metadata` takes care of this by reading the Settings and returning XML.  All you have to do is add a controller to return the data, then give this URL to the IdP administrator.

The metadata will be polled by the IdP every few minutes, so updating your settings should propagate
to the IdP settings.

```ruby
class SamlController < ApplicationController
  # ... the rest of your controller definitions ...
  def metadata
    settings = Account.get_saml_settings
    meta = OneLogin::RubySaml::Metadata.new
    render :xml => meta.generate(settings), :content_type => "application/samlmetadata+xml"
  end
end
```

You can add `ValidUntil` and `CacheDuration` to the SP Metadata XML using instead:

```ruby
  # Valid until => 2 days from now
  # Cache duration = 604800s = 1 week
  valid_until = Time.now + 172800
  cache_duration = 604800
  meta.generate(settings, false, valid_until, cache_duration)
```

## Signing and Decryption

Ruby SAML supports the following functionality:

1. Signing your SP Metadata XML
2. Signing your SP SAML messages
3. Decrypting IdP Assertion messages upon receipt (EncryptedAssertion)
4. Verifying signatures on SAML messages and IdP Assertions

In order to use functions 1-3 above, you must first define your SP public certificate and private key:

```ruby
  settings.certificate = "CERTIFICATE TEXT WITH BEGIN/END HEADER AND FOOTER"
  settings.private_key = "PRIVATE KEY TEXT WITH BEGIN/END HEADER AND FOOTER"
```

Note that the same certificate (and its associated private key) are used to perform
all decryption and signing-related functions (1-4) above. Ruby SAML does not currently allow
to specify different certificates for each function.

You may also globally set the SP signature and digest method, to be used in SP signing (functions 1 and 2 above):

```ruby
  settings.security[:digest_method]    = XMLSecurity::Document::SHA1
  settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1
```

#### Signing SP Metadata

You may add a `<ds:Signature>` digital signature element to your SP Metadata XML using the following setting:

```ruby
  settings.certificate = "CERTIFICATE TEXT WITH BEGIN/END HEADER AND FOOTER"
  settings.private_key = "PRIVATE KEY TEXT WITH BEGIN/END HEADER AND FOOTER"

  settings.security[:metadata_signed] = true # Enable signature on Metadata
```

#### Signing SP SAML Messages

Ruby SAML supports SAML request signing. The Service Provider will sign the
request/responses with its private key. The Identity Provider will then validate the signature
of the received request/responses with the public X.509 cert of the Service Provider.

To enable, please first set your certificate and private key. This will add `<md:KeyDescriptor use="signing">`
to your SP Metadata XML, to be read by the IdP.

```ruby
  settings.certificate = "CERTIFICATE TEXT WITH BEGIN/END HEADER AND FOOTER"
  settings.private_key = "PRIVATE KEY TEXT WITH BEGIN/END HEADER AND FOOTER"
```

Next, you may specify the specific SP SAML messages you would like to sign:

```ruby
  settings.security[:authn_requests_signed]   = true  # Enable signature on AuthNRequest
  settings.security[:logout_requests_signed]  = true  # Enable signature on Logout Request
  settings.security[:logout_responses_signed] = true  # Enable signature on Logout Response
```

Signatures will be handled automatically for both `HTTP-Redirect` and `HTTP-Redirect` Binding.
Note that the RelayState parameter is used when creating the Signature on the `HTTP-Redirect` Binding.
Remember to provide it to the Signature builder if you are sending a `GET RelayState` parameter or the
signature validation process will fail at the Identity Provider.

#### Decrypting IdP SAML Assertions

Ruby SAML supports EncryptedAssertion. The Identity Provider will encrypt the Assertion with the
public cert of the Service Provider. The Service Provider will decrypt the EncryptedAssertion with its private key.

You may enable EncryptedAssertion as follows. This will add `<md:KeyDescriptor use="encrytion">` to your
SP Metadata XML, to be read by the IdP.

```ruby
  settings.certificate = "CERTIFICATE TEXT WITH BEGIN/END HEADER AND FOOTER"
  settings.private_key = "PRIVATE KEY TEXT WITH BEGIN/END HEADER AND FOOTER"

  settings.security[:want_assertions_encrypted] = true # Invalidate SAML messages without an EncryptedAssertion
```

#### Verifying Signature on IdP Assertions

You may require the IdP to sign its SAML Assertions using the following setting.
With will add `<md:SPSSODescriptor WantAssertionsSigned="true">` to your SP Metadata XML.
The signature will be checked against the `<md:KeyDescriptor use="signing">` element
present in the IdP's metadata.

```ruby
  settings.security[:want_assertions_signed]  = true  # Require the IdP to sign its SAML Assertions
```

#### Certificate and Signature Validation

You may require SP and IdP certificates to be non-expired using the following settings:

```ruby
  settings.security[:check_idp_cert_expiration] = true  # Raise error if IdP X.509 cert is expired
  settings.security[:check_sp_cert_expiration] = true   # Raise error SP X.509 cert is expired
```

By default, Ruby SAML will raise a `OneLogin::RubySaml::ValidationError` if a signature or certificate
validation fails. You may disable such exceptions using the `settings.security[:soft]` parameter.

```ruby
  settings.security[:soft] = true  # Do not raise error on failed signature/certificate validations
```

#### Audience Validation

A service provider should only consider a SAML response valid if the IdP includes an <AudienceRestriction>
element containting an <Audience> element that uniquely identifies the service provider. Unless you specify
the `skip_audience` option, Ruby SAML will validate that each SAML response includes an <Audience> element
whose contents matches `settings.sp_entity_id`.

By default, Ruby SAML considers an <AudienceRestriction> element containing only empty <Audience> elements
to be valid. That means an otherwise valid SAML response with a condition like this would be valid:

```xml
<AudienceRestriction>
  <Audience />
</AudienceRestriction>
```

You may enforce that an <AudienceRestriction> element containing only empty <Audience> elements
is invalid using the `settings.security[:strict_audience_validation]` parameter.

```ruby
settings.security[:strict_audience_validation] = true
```

#### Key Rollover

To update the SP X.509 certificate and private key without disruption of service, you may define the parameter
`settings.certificate_new`. This will publish the new SP certificate in your metadata so that your IdP counterparties
may cache it in preparation for rollover.

For example, if you to rollover from `CERT A` to `CERT B`. Before rollover, your settings should look as follows.
Both `CERT A` and `CERT B` will now appear in your SP metadata, however `CERT A` will still be used for signing
and encryption at this time.

```ruby
  settings.certificate = "CERT A"
  settings.private_key = "PRIVATE KEY FOR CERT A"
  settings.certificate_new = "CERT B"
```

After the IdP has cached `CERT B`, you may then change your settings as follows:

```ruby
  settings.certificate = "CERT B"
  settings.private_key = "PRIVATE KEY FOR CERT B"
```

## Single Log Out

Ruby SAML supports SP-initiated Single Logout and IdP-Initiated Single Logout.

Here is an example that we could add to our previous controller to generate and send a SAML Logout Request to the IdP:

```ruby
# Create a SP initiated SLO
def sp_logout_request
  # LogoutRequest accepts plain browser requests w/o paramters
  settings = saml_settings

  if settings.idp_slo_service_url.nil?
    logger.info "SLO IdP Endpoint not found in settings, executing then a normal logout'"
    delete_session
  else

    logout_request = OneLogin::RubySaml::Logoutrequest.new
    logger.info "New SP SLO for userid '#{session[:userid]}' transactionid '#{logout_request.uuid}'"

    if settings.name_identifier_value.nil?
      settings.name_identifier_value = session[:userid]
    end

    # Ensure user is logged out before redirect to IdP, in case anything goes wrong during single logout process (as recommended by saml2int [SDP-SP34])
    logged_user = session[:userid]
    logger.info "Delete session for '#{session[:userid]}'"
    delete_session

    # Save the transaction_id to compare it with the response we get back
    session[:transaction_id] = logout_request.uuid
    session[:logged_out_user] = logged_user

    relayState = url_for(controller: 'saml', action: 'index')
    redirect_to(logout_request.create(settings, :RelayState => relayState))
  end
end
```

This method processes the SAML Logout Response sent by the IdP as the reply of the SAML Logout Request:

```ruby
# After sending an SP initiated LogoutRequest to the IdP, we need to accept
# the LogoutResponse, verify it, then actually delete our session.
def process_logout_response
  settings = Account.get_saml_settings

  if session.has_key? :transaction_id
    logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings, :matches_request_id => session[:transaction_id])
  else
    logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings)
  end

  logger.info "LogoutResponse is: #{logout_response.to_s}"

  # Validate the SAML Logout Response
  if not logout_response.validate
    logger.error "The SAML Logout Response is invalid"
  else
    # Actually log out this session
    logger.info "SLO completed for '#{session[:logged_out_user]}'"
    delete_session
  end
end

# Delete a user's session.
def delete_session
  session[:userid] = nil
  session[:attributes] = nil
  session[:transaction_id] = nil
  session[:logged_out_user] = nil
end
```

Here is an example that we could add to our previous controller to process a SAML Logout Request from the IdP and reply with a SAML Logout Response to the IdP:

```ruby
# Method to handle IdP initiated logouts
def idp_logout_request
  settings = Account.get_saml_settings
  # ADFS URL-Encodes SAML data as lowercase, and the toolkit by default uses
  # uppercase. Turn it True for ADFS compatibility on signature verification
  settings.security[:lowercase_url_encoding] = true

  logout_request = OneLogin::RubySaml::SloLogoutrequest.new(
    params[:SAMLRequest], settings: settings
  )
  if !logout_request.is_valid?
    logger.error "IdP initiated LogoutRequest was not valid!"
    return render :inline => logger.error
  end
  logger.info "IdP initiated Logout for #{logout_request.name_id}"

  # Actually log out this session
  delete_session

  # Generate a response to the IdP.
  logout_request_id = logout_request.id
  logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create(settings, logout_request_id, nil, :RelayState => params[:RelayState])
  redirect_to logout_response
end
```

All the mentioned methods could be handled in a unique view:

```ruby
# Trigger SP and IdP initiated Logout requests
def logout
  # If we're given a logout request, handle it in the IdP logout initiated method
  if params[:SAMLRequest]
    return idp_logout_request
  # We've been given a response back from the IdP, process it
  elsif params[:SAMLResponse]
    return process_logout_response
  # Initiate SLO (send Logout Request)
  else
    return sp_logout_request
  end
end
```

## Clock Drift

Server clocks tend to drift naturally. If during validation of the response you get the error "Current time is earlier than NotBefore condition", this may be due to clock differences between your system and that of the Identity Provider.

First, ensure that both systems synchronize their clocks, using for example the industry standard [Network Time Protocol (NTP)](http://en.wikipedia.org/wiki/Network_Time_Protocol).

Even then you may experience intermittent issues, as the clock of the Identity Provider may drift slightly ahead of your system clocks. To allow for a small amount of clock drift, you can initialize the response by passing in an option named `:allowed_clock_drift`. Its value must be given in a number (and/or fraction) of seconds. The value given is added to the current time at which the response is validated before it's tested against the `NotBefore` assertion. For example:

```ruby
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :allowed_clock_drift => 1.second)
```

Make sure to keep the value as comfortably small as possible to keep security risks to a minimum.

## Deflation Limit

To protect against decompression bombs (a form of DoS attack), SAML messages are limited to 250,000 bytes by default.
Sometimes legitimate SAML messages will exceed this limit,
for example due to custom claims like including groups a user is a member of.
If you want to customize this limit, you need to provide a different setting when initializing the response object.
Example:

```ruby
def consume
  response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], { settings: saml_settings })
  ...
end

private

def saml_settings
  OneLogin::RubySaml::Settings.new(message_max_bytesize: 500_000)
end
```

## Attribute Service

To request attributes from the IdP the SP needs to provide an attribute service within it's metadata and reference the index in the assertion.

```ruby
settings = OneLogin::RubySaml::Settings.new
settings.attributes_index = 5
settings.attribute_consuming_service.configure do
  service_name "Service"
  service_index 5
  add_attribute :name => "Name", :name_format => "Name Format", :friendly_name => "Friendly Name"
  add_attribute :name => "Another Attribute", :name_format => "Name Format", :friendly_name => "Friendly Name", :attribute_value => "Attribute Value"
end
```

The `attribute_value` option additionally accepts an array of possible values.

## Custom Metadata Fields

Some IdPs may require to add SPs to add additional fields (Organization, ContactPerson, etc.)
into the SP metadata. This can be achieved by extending the `OneLogin::RubySaml::Metadata`
class and overriding the `#add_extras` method as per the following example:

```ruby
class MyMetadata < OneLogin::RubySaml::Metadata
  def add_extras(root, _settings)
    org = root.add_element("md:Organization")
    org.add_element("md:OrganizationName", 'xml:lang' => "en-US").text = 'ACME Inc.'
    org.add_element("md:OrganizationDisplayName", 'xml:lang' => "en-US").text = 'ACME'
    org.add_element("md:OrganizationURL", 'xml:lang' => "en-US").text = 'https://www.acme.com'

    cp = root.add_element("md:ContactPerson", 'contactType' => 'technical')
    cp.add_element("md:GivenName").text = 'ACME SAML Team'
    cp.add_element("md:EmailAddress").text = 'saml@acme.com'
  end
end

# Output XML with custom metadata
MyMetadata.new.generate(settings)
```
