# frozen_string_literal: true

module Lti
  # Verifies an LTI 1.3 id_token against a registered platform deployment.
  # LTI message-level claims are validated by the launch controller.
  class JwtValidator
    LEEWAY = 30
    JWKS_TIMEOUT = 5
    JWKS_CACHE_TTL = 5.minutes

    class ValidationError < StandardError; end

    class << self
      def validate!(token, deployment:, nonce:)
        encoded_token = JWT::EncodedToken.new(token)
        verify_token!(encoded_token, deployment)

        payload = encoded_token.payload
        verify_nonce!(payload, nonce)
        verify_audience!(payload, deployment)
        raise ValidationError, "Missing sub claim" if payload["sub"].blank?

        payload
      rescue JWT::DecodeError => e
        raise ValidationError, e.message
      end

      private

        # The header is read unverified only to pick a candidate key; the
        # signature is then checked against an explicit RS256 allow-list, and
        # #payload refuses to decode until both it and the claims have passed.
        def verify_token!(encoded_token, deployment)
          encoded_token.verify_signature!(
            algorithm: "RS256",
            key: fetch_platform_key(deployment, encoded_token.header["kid"])
          )
          encoded_token.verify_claims!(
            iss: deployment.issuer,
            aud: deployment.client_id,
            exp: { leeway: LEEWAY }
          )
        end

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

        def fetch_platform_key(deployment, kid)
          key_from_jwks(deployment, kid) ||
            key_from_stored(deployment) ||
            raise(ValidationError, "Could not obtain platform public key")
        end

        def key_from_jwks(deployment, kid)
          return if deployment.jwks_url.blank?

          jwk = find_jwk(deployment, kid)
          JWT::JWK.import(jwk).public_key if jwk
        end

        # A kid missing from the cached set means the platform may have rotated,
        # so refetch rather than waiting for the cache to expire.
        def find_jwk(deployment, kid)
          cache_key = "lti/jwks:v1:#{deployment.jwks_url}"
          cached = Array(Rails.cache.read(cache_key)).find { |k| k["kid"] == kid }
          return cached if cached

          keys = fetch_jwks(deployment)
          Rails.cache.write(cache_key, keys, expires_in: JWKS_CACHE_TTL) if keys
          Array(keys).find { |k| k["kid"] == kid }
        end

        def fetch_jwks(deployment)
          response = Faraday.get(deployment.jwks_url) do |req|
            req.options.open_timeout = JWKS_TIMEOUT
            req.options.timeout = JWKS_TIMEOUT
          end
          return unless response.success? && response.headers["content-type"]&.include?("json")

          Array(JSON.parse(response.body)["keys"])
        rescue Faraday::Error, JSON::ParserError => e
          Rails.logger.warn("LTI JWKS fetch failed for #{deployment.jwks_url}: #{e.message}")
          nil
        end

        def key_from_stored(deployment)
          return if deployment.platform_public_key.blank?

          OpenSSL::PKey::RSA.new(deployment.platform_public_key)
        rescue OpenSSL::PKey::RSAError => e
          Rails.logger.warn("LTI stored key invalid: #{e.message}")
          nil
        end
    end
  end
end
