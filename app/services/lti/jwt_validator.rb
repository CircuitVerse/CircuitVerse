# frozen_string_literal: true

module Lti
  class JwtValidator
    LEEWAY = 30
    JWKS_TIMEOUT = 5
    JWKS_CACHE_TTL = 5.minutes

    class ValidationError < StandardError; end

    class << self
      def validate!(token, deployment:, nonce:)
        # EncodedToken raises ArgumentError, not a JWT error, on a missing or
        # non-String token, so reject that here rather than widening the rescue.
        raise ValidationError, "Missing id_token" unless token.is_a?(String)

        encoded_token = JWT::EncodedToken.new(token)
        verify_token!(encoded_token, deployment)

        payload = encoded_token.payload
        verify_nonce!(payload, nonce)
        verify_audience!(payload, deployment)
        verify_subject!(payload)

        payload
      rescue JWT::DecodeError => e
        raise ValidationError, e.message
      end

      private

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

        def verify_subject!(payload)
          sub = payload["sub"]
          raise ValidationError, "Missing sub claim" unless sub.is_a?(String) && sub.present?
        end

        def verify_nonce!(payload, nonce)
          raise ValidationError, "Missing nonce" if nonce.blank?
          raise ValidationError, "Nonce mismatch" if payload["nonce"] != nonce
        end

        def verify_audience!(payload, deployment)
          aud = payload["aud"]
          return unless aud.is_a?(Array) && aud.size > 1
          return if payload["azp"] == deployment.client_id

          raise ValidationError, "azp does not match client_id"
        end

        def fetch_platform_key(deployment, kid)
          key_from_jwks(deployment, kid) ||
            raise(ValidationError, "Could not obtain platform public key")
        end

        def key_from_jwks(deployment, kid)
          return unless fetchable_jwks_url?(deployment.jwks_url)

          jwk = find_jwk(deployment, kid)
          JWT::JWK.import(jwk).public_key if jwk
        end

        def find_jwk(deployment, kid)
          cache_key = "lti/jwks:v1:#{deployment.jwks_url}"
          cached = Array(Rails.cache.read(cache_key)).find { |k| k["kid"] == kid }
          return cached if cached

          keys = fetch_jwks(deployment)
          Rails.cache.write(cache_key, keys, expires_in: JWKS_CACHE_TTL) if keys
          Array(keys).find { |k| k["kid"] == kid }
        end

        def fetch_jwks(deployment)
          response = HTTP.timeout(JWKS_TIMEOUT).get(deployment.jwks_url)
          return unless response.status.success? && response.content_type.mime_type&.include?("json")

          Array(JSON.parse(response.body.to_s)["keys"])
        rescue HTTP::Error, JSON::ParserError => e
          Rails.logger.warn("LTI JWKS fetch failed for #{deployment.jwks_url}: #{e.message}")
          nil
        end

        def fetchable_jwks_url?(url)
          uri = URI.parse(url.to_s)
          return false if uri.host.blank?

          uri.is_a?(URI::HTTPS) || (uri.is_a?(URI::HTTP) && !Rails.env.production?)
        rescue URI::InvalidURIError
          false
        end
    end
  end
end
