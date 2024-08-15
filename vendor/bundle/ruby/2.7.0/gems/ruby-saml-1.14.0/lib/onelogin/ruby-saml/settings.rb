require "xml_security"
require "onelogin/ruby-saml/attribute_service"
require "onelogin/ruby-saml/utils"
require "onelogin/ruby-saml/validation_error"

# Only supports SAML 2.0
module OneLogin
  module RubySaml

    # SAML2 Toolkit Settings
    #
    class Settings
      def initialize(overrides = {}, keep_security_attributes = false)
        if keep_security_attributes
          security_attributes = overrides.delete(:security) || {}
          config = DEFAULTS.merge(overrides)
          config[:security] = DEFAULTS[:security].merge(security_attributes)
        else
          config = DEFAULTS.merge(overrides)
        end

        config.each do |k,v|
          acc = "#{k.to_s}=".to_sym
          if respond_to? acc
            value = v.is_a?(Hash) ? v.dup : v
            send(acc, value)
          end
        end
        @attribute_consuming_service = AttributeService.new
      end

      # IdP Data
      attr_accessor :idp_entity_id
      attr_writer   :idp_sso_service_url
      attr_writer   :idp_slo_service_url
      attr_accessor :idp_slo_response_service_url
      attr_accessor :idp_cert
      attr_accessor :idp_cert_fingerprint
      attr_accessor :idp_cert_fingerprint_algorithm
      attr_accessor :idp_cert_multi
      attr_accessor :idp_attribute_names
      attr_accessor :idp_name_qualifier
      attr_accessor :valid_until
      # SP Data
      attr_writer   :sp_entity_id
      attr_accessor :assertion_consumer_service_url
      attr_reader   :assertion_consumer_service_binding
      attr_writer   :single_logout_service_url
      attr_accessor :sp_name_qualifier
      attr_accessor :name_identifier_format
      attr_accessor :name_identifier_value
      attr_accessor :name_identifier_value_requested
      attr_accessor :sessionindex
      attr_accessor :compress_request
      attr_accessor :compress_response
      attr_accessor :double_quote_xml_attribute_values
      attr_accessor :message_max_bytesize
      attr_accessor :passive
      attr_reader   :protocol_binding
      attr_accessor :attributes_index
      attr_accessor :force_authn
      attr_accessor :certificate
      attr_accessor :certificate_new
      attr_accessor :private_key
      attr_accessor :authn_context
      attr_accessor :authn_context_comparison
      attr_accessor :authn_context_decl_ref
      attr_reader :attribute_consuming_service
      # Work-flow
      attr_accessor :security
      attr_accessor :soft
      # Deprecated
      attr_accessor :assertion_consumer_logout_service_url
      attr_reader   :assertion_consumer_logout_service_binding
      attr_accessor :issuer
      attr_accessor :idp_sso_target_url
      attr_accessor :idp_slo_target_url

      # @return [String] IdP Single Sign On Service URL
      #
      def idp_sso_service_url
        @idp_sso_service_url || @idp_sso_target_url
      end

      # @return [String] IdP Single Logout Service URL
      #
      def idp_slo_service_url
        @idp_slo_service_url || @idp_slo_target_url
      end

      # @return [String] IdP Single Sign On Service Binding
      #
      def idp_sso_service_binding
        @idp_sso_service_binding || idp_binding_from_embed_sign
      end

      # Setter for IdP Single Sign On Service Binding
      # @param value [String, Symbol].
      #
      def idp_sso_service_binding=(value)
        @idp_sso_service_binding = get_binding(value)
      end

      # @return [String] IdP Single Logout Service Binding
      #
      def idp_slo_service_binding
        @idp_slo_service_binding || idp_binding_from_embed_sign
      end

      # Setter for IdP Single Logout Service Binding
      # @param value [String, Symbol].
      #
      def idp_slo_service_binding=(value)
        @idp_slo_service_binding = get_binding(value)
      end

      # @return [String] SP Entity ID
      #
      def sp_entity_id
        @sp_entity_id || @issuer
      end

      # Setter for SP Protocol Binding
      # @param value [String, Symbol].
      #
      def protocol_binding=(value)
        @protocol_binding = get_binding(value)
      end

      # Setter for SP Assertion Consumer Service Binding
      # @param value [String, Symbol].
      #
      def assertion_consumer_service_binding=(value)
        @assertion_consumer_service_binding = get_binding(value)
      end

      # @return [String] Single Logout Service URL.
      #
      def single_logout_service_url
        @single_logout_service_url || @assertion_consumer_logout_service_url
      end

      # @return [String] Single Logout Service Binding.
      #
      def single_logout_service_binding
        @single_logout_service_binding || @assertion_consumer_logout_service_binding
      end

      # Setter for Single Logout Service Binding.
      #
      # (Currently we only support "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect")
      # @param value [String, Symbol]
      #
      def single_logout_service_binding=(value)
        @single_logout_service_binding = get_binding(value)
      end

      # @deprecated Setter for legacy Single Logout Service Binding parameter.
      #
      # (Currently we only support "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect")
      # @param value [String, Symbol]
      #
      def assertion_consumer_logout_service_binding=(value)
        @assertion_consumer_logout_service_binding = get_binding(value)
      end

      # Calculates the fingerprint of the IdP x509 certificate.
      # @return [String] The fingerprint
      #
      def get_fingerprint
        idp_cert_fingerprint || begin
          idp_cert = get_idp_cert
          if idp_cert
            fingerprint_alg = XMLSecurity::BaseDocument.new.algorithm(idp_cert_fingerprint_algorithm).new
            fingerprint_alg.hexdigest(idp_cert.to_der).upcase.scan(/../).join(":")
          end
        end
      end

      # @return [OpenSSL::X509::Certificate|nil] Build the IdP certificate from the settings (previously format it)
      #
      def get_idp_cert
        return nil if idp_cert.nil? || idp_cert.empty?

        formatted_cert = OneLogin::RubySaml::Utils.format_cert(idp_cert)
        OpenSSL::X509::Certificate.new(formatted_cert)
      end

      # @return [Hash with 2 arrays of OpenSSL::X509::Certificate] Build multiple IdP certificates from the settings.
      #
      def get_idp_cert_multi
        return nil if idp_cert_multi.nil? || idp_cert_multi.empty?

        raise ArgumentError.new("Invalid value for idp_cert_multi") if not idp_cert_multi.is_a?(Hash)

        certs = {:signing => [], :encryption => [] }

        if idp_cert_multi.key?(:signing) and not idp_cert_multi[:signing].empty?
          idp_cert_multi[:signing].each do |idp_cert|
            formatted_cert = OneLogin::RubySaml::Utils.format_cert(idp_cert)
            certs[:signing].push(OpenSSL::X509::Certificate.new(formatted_cert))
          end
        end

        if idp_cert_multi.key?(:encryption) and not idp_cert_multi[:encryption].empty?
          idp_cert_multi[:encryption].each do |idp_cert|
            formatted_cert = OneLogin::RubySaml::Utils.format_cert(idp_cert)
            certs[:encryption].push(OpenSSL::X509::Certificate.new(formatted_cert))
          end
        end

        certs
      end

      # @return [OpenSSL::X509::Certificate|nil] Build the SP certificate from the settings (previously format it)
      #
      def get_sp_cert
        return nil if certificate.nil? || certificate.empty?

        formatted_cert = OneLogin::RubySaml::Utils.format_cert(certificate)
        cert = OpenSSL::X509::Certificate.new(formatted_cert)

        if security[:check_sp_cert_expiration]
          if OneLogin::RubySaml::Utils.is_cert_expired(cert)
            raise OneLogin::RubySaml::ValidationError.new("The SP certificate expired.")
          end
        end

        cert
      end

      # @return [OpenSSL::X509::Certificate|nil] Build the New SP certificate from the settings (previously format it)
      #
      def get_sp_cert_new
        return nil if certificate_new.nil? || certificate_new.empty?

        formatted_cert = OneLogin::RubySaml::Utils.format_cert(certificate_new)
        OpenSSL::X509::Certificate.new(formatted_cert)
      end

      # @return [OpenSSL::PKey::RSA] Build the SP private from the settings (previously format it)
      #
      def get_sp_key
        return nil if private_key.nil? || private_key.empty?

        formatted_private_key = OneLogin::RubySaml::Utils.format_private_key(private_key)
        OpenSSL::PKey::RSA.new(formatted_private_key)
      end

      private

      def idp_binding_from_embed_sign
        security[:embed_sign] ? Utils::BINDINGS[:post] : Utils::BINDINGS[:redirect]
      end

      def get_binding(value)
        return unless value

        Utils::BINDINGS[value.to_sym] || value
      end

      DEFAULTS = {
        :assertion_consumer_service_binding        => Utils::BINDINGS[:post],
        :single_logout_service_binding             => Utils::BINDINGS[:redirect],
        :idp_cert_fingerprint_algorithm            => XMLSecurity::Document::SHA1,
        :compress_request                          => true,
        :compress_response                         => true,
        :message_max_bytesize                      => 250000,
        :soft                                      => true,
        :double_quote_xml_attribute_values         => false,
        :security                                  => {
          :authn_requests_signed      => false,
          :logout_requests_signed     => false,
          :logout_responses_signed    => false,
          :want_assertions_signed     => false,
          :want_assertions_encrypted  => false,
          :want_name_id               => false,
          :metadata_signed            => false,
          :embed_sign                 => false, # Deprecated
          :digest_method              => XMLSecurity::Document::SHA1,
          :signature_method           => XMLSecurity::Document::RSA_SHA1,
          :check_idp_cert_expiration  => false,
          :check_sp_cert_expiration   => false,
          :strict_audience_validation => false,
          :lowercase_url_encoding     => false
        }.freeze
      }.freeze
    end
  end
end
