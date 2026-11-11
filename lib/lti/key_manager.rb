# frozen_string_literal: true

module Lti
  class KeyManager
    DEV_KEY_PATH = Rails.root.join("tmp/lti_tool_key.pem")

    class << self
      def private_key
        @private_key ||= load_key
      end

      def public_jwk
        jwk = JSON::JWK.new(private_key.public_key)
        jwk[:kid] ||= jwk.thumbprint
        jwk.merge(use: "sig", alg: "RS256")
      end

      def reset!
        @private_key = nil
      end

      private

        def load_key
          pem = ENV.fetch("LTI_TOOL_PRIVATE_KEY", nil)
          return OpenSSL::PKey::RSA.new(pem) if pem.present?
          raise KeyError, "LTI_TOOL_PRIVATE_KEY is not set" if Rails.env.production?

          local_key
        end

        def local_key
          return OpenSSL::PKey::RSA.new(DEV_KEY_PATH.read) if DEV_KEY_PATH.exist?

          key = OpenSSL::PKey::RSA.new(2048)
          DEV_KEY_PATH.write(key.to_pem)
          key
        end
    end
  end
end
