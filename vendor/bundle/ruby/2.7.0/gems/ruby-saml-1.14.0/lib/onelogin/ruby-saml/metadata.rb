require "uri"

require "onelogin/ruby-saml/logging"
require "onelogin/ruby-saml/utils"

# Only supports SAML 2.0
module OneLogin
  module RubySaml

    # SAML2 Metadata. XML Metadata Builder
    #
    class Metadata

      # Return SP metadata based on the settings.
      # @param settings [OneLogin::RubySaml::Settings|nil] Toolkit settings
      # @param pretty_print [Boolean] Pretty print or not the response
      #                               (No pretty print if you gonna validate the signature)
      # @param valid_until [DateTime] Metadata's valid time
      # @param cache_duration [Integer] Duration of the cache in seconds
      # @return [String] XML Metadata of the Service Provider
      #
      def generate(settings, pretty_print=false, valid_until=nil, cache_duration=nil)
        meta_doc = XMLSecurity::Document.new
        add_xml_declaration(meta_doc)
        root = add_root_element(meta_doc, settings, valid_until, cache_duration)
        sp_sso = add_sp_sso_element(root, settings)
        add_sp_certificates(sp_sso, settings)
        add_sp_service_elements(sp_sso, settings)
        add_extras(root, settings)
        embed_signature(meta_doc, settings)
        output_xml(meta_doc, pretty_print)
      end

      protected

      def add_xml_declaration(meta_doc)
        meta_doc << REXML::XMLDecl.new('1.0', 'UTF-8')
      end

      def add_root_element(meta_doc, settings, valid_until, cache_duration)
        namespaces = {
            "xmlns:md" => "urn:oasis:names:tc:SAML:2.0:metadata"
        }

        if settings.attribute_consuming_service.configured?
          namespaces["xmlns:saml"] = "urn:oasis:names:tc:SAML:2.0:assertion"
        end

        root = meta_doc.add_element("md:EntityDescriptor", namespaces)
        root.attributes["ID"] = OneLogin::RubySaml::Utils.uuid
        root.attributes["entityID"] = settings.sp_entity_id if settings.sp_entity_id
        root.attributes["validUntil"] = valid_until.strftime('%Y-%m-%dT%H:%M:%S%z') if valid_until
        root.attributes["cacheDuration"] = "PT" + cache_duration.to_s + "S" if cache_duration
        root
      end

      def add_sp_sso_element(root, settings)
        root.add_element "md:SPSSODescriptor", {
            "protocolSupportEnumeration" => "urn:oasis:names:tc:SAML:2.0:protocol",
            "AuthnRequestsSigned" => settings.security[:authn_requests_signed],
            "WantAssertionsSigned" => settings.security[:want_assertions_signed],
        }
      end

      # Add KeyDescriptor if messages will be signed / encrypted
      # with SP certificate, and new SP certificate if any
      def add_sp_certificates(sp_sso, settings)
        cert = settings.get_sp_cert
        cert_new = settings.get_sp_cert_new

        for sp_cert in [cert, cert_new]
          if sp_cert
            cert_text = Base64.encode64(sp_cert.to_der).gsub("\n", '')
            kd = sp_sso.add_element "md:KeyDescriptor", { "use" => "signing" }
            ki = kd.add_element "ds:KeyInfo", {"xmlns:ds" => "http://www.w3.org/2000/09/xmldsig#"}
            xd = ki.add_element "ds:X509Data"
            xc = xd.add_element "ds:X509Certificate"
            xc.text = cert_text

            if settings.security[:want_assertions_encrypted]
              kd2 = sp_sso.add_element "md:KeyDescriptor", { "use" => "encryption" }
              ki2 = kd2.add_element "ds:KeyInfo", {"xmlns:ds" => "http://www.w3.org/2000/09/xmldsig#"}
              xd2 = ki2.add_element "ds:X509Data"
              xc2 = xd2.add_element "ds:X509Certificate"
              xc2.text = cert_text
            end
          end
        end

        sp_sso
      end

      def add_sp_service_elements(sp_sso, settings)
        if settings.single_logout_service_url
          sp_sso.add_element "md:SingleLogoutService", {
              "Binding" => settings.single_logout_service_binding,
              "Location" => settings.single_logout_service_url,
              "ResponseLocation" => settings.single_logout_service_url
          }
        end

        if settings.name_identifier_format
          nameid = sp_sso.add_element "md:NameIDFormat"
          nameid.text = settings.name_identifier_format
        end

        if settings.assertion_consumer_service_url
          sp_sso.add_element "md:AssertionConsumerService", {
              "Binding" => settings.assertion_consumer_service_binding,
              "Location" => settings.assertion_consumer_service_url,
              "isDefault" => true,
              "index" => 0
          }
        end

        if settings.attribute_consuming_service.configured?
          sp_acs = sp_sso.add_element "md:AttributeConsumingService", {
            "isDefault" => "true",
            "index" => settings.attribute_consuming_service.index
          }
          srv_name = sp_acs.add_element "md:ServiceName", {
            "xml:lang" => "en"
          }
          srv_name.text = settings.attribute_consuming_service.name
          settings.attribute_consuming_service.attributes.each do |attribute|
            sp_req_attr = sp_acs.add_element "md:RequestedAttribute", {
              "NameFormat" => attribute[:name_format],
              "Name" => attribute[:name],
              "FriendlyName" => attribute[:friendly_name],
              "isRequired" => attribute[:is_required] || false
            }
            unless attribute[:attribute_value].nil?
              Array(attribute[:attribute_value]).each do |value|
                sp_attr_val = sp_req_attr.add_element "saml:AttributeValue"
                sp_attr_val.text = value.to_s
              end
            end
          end
        end

        # With OpenSSO, it might be required to also include
        #  <md:RoleDescriptor xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:query="urn:oasis:names:tc:SAML:metadata:ext:query" xsi:type="query:AttributeQueryDescriptorType" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol"/>
        #  <md:XACMLAuthzDecisionQueryDescriptor WantAssertionsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol"/>

        sp_sso
      end

      # can be overridden in subclass
      def add_extras(root, _settings)
        root
      end

      def embed_signature(meta_doc, settings)
        return unless settings.security[:metadata_signed]

        private_key = settings.get_sp_key
        cert = settings.get_sp_cert
        return unless private_key && cert

        meta_doc.sign_document(private_key, cert, settings.security[:signature_method], settings.security[:digest_method])
      end

      def output_xml(meta_doc, pretty_print)
        ret = ''

        # pretty print the XML so IdP administrators can easily see what the SP supports
        if pretty_print
          meta_doc.write(ret, 1)
        else
          ret = meta_doc.to_s
        end

        ret
      end
    end
  end
end
