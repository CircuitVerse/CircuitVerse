# frozen_string_literal: true

module Lti
  # Verifies an LTI 1.3 id_token against a registered platform deployment.
  # LTI message-level claims are validated by the launch controller.
  class JwtValidator
    LEEWAY = 30
    JWKS_TIMEOUT = 5

    class ValidationError < StandardError; end

    class << self
      def validate!(token, deployment:, nonce:)
        key = fetch_platform_key(deployment, token)
        payload, = JWT.decode(
          token, key, true,
          algorithms: ["RS256"],
          iss: deployment.issuer, verify_iss: true,
          aud: deployment.client_id, verify_aud: true,
          verify_expiration: true, leeway: LEEWAY
        )

        verify_nonce!(payload, nonce)
        verify_audience!(payload, deployment)
        raise ValidationError, "Missing sub claim" if payload["sub"].blank?

        payload
      rescue JWT::DecodeError => e
        raise ValidationError, e.message
      end

      private

        def verify_nonce!(payload, nonce)
          raise ValidationError, "Missing nonce" if nonce.blank?
          raise ValidationError, "Nonce mismatch" if payload["nonce"] != nonce
        end

        # When aud is an array of more than one value, azp must name our client_id.
        def verify_audience!(payload, deployment)
          aud = payload["aud"]
          return unless aud.is_a?(Array) && aud.size > 1
          return if payload["azp"] == deployment.client_id

          raise ValidationError, "azp does not match client_id"
        end

        def fetch_platform_key(deployment, token)
          _, header = JWT.decode(token, nil, false)
          key_from_jwks(deployment, header["kid"]) ||
            key_from_stored(deployment) ||
            raise(ValidationError, "Could not obtain platform public key")
        end

        def key_from_jwks(deployment, kid)
          response = Faraday.get(deployment.jwks_url) do |req|
            req.options.open_timeout = JWKS_TIMEOUT
            req.options.timeout = JWKS_TIMEOUT
          end
          return unless response.success? && response.headers["content-type"]&.include?("json")

          key = Array(JSON.parse(response.body)["keys"]).find { |k| k["kid"] == kid }
          JWT::JWK.import(key).public_key if key
        rescue Faraday::Error, JSON::ParserError => e
          Rails.logger.warn("LTI JWKS fetch failed for #{deployment.jwks_url}: #{e.message}")
          nil
        end

        def key_from_stored(deployment)
          OpenSSL::PKey::RSA.new(deployment.platform_public_key) if deployment.platform_public_key.present?
        end
    end
  end
end
