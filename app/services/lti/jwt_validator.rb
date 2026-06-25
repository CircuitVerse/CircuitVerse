# frozen_string_literal: true

module Lti
  class JwtValidator
    REQUIRED_CLAIMS = %w[sub iss aud nonce].freeze

    def self.validate!(token, deployment:, nonce:)
      platform_key = fetch_platform_key(deployment, token)

      payload, _header = JWT.decode(
        token,
        platform_key,
        true,
        algorithms:  ["RS256"],
        iss:         deployment.issuer,
        aud:         deployment.client_id,
        verify_iss:  true,
        verify_aud:  true
      )

      raise SecurityError, "Nonce mismatch" if nonce.present? && payload["nonce"] != nonce
      raise ArgumentError, "Missing required claims" \
        unless REQUIRED_CLAIMS.all? { |c| payload.key?(c) }

      payload
    end

    private

    def self.fetch_platform_key(deployment, token)
      _payload, header = JWT.decode(token, nil, false)
      kid = header["kid"]

      # Try JWKS URL first
      begin
        response = Faraday.get(deployment.jwks_url)
        if response.success? && response.headers["content-type"]&.include?("json")
          jwks     = JSON.parse(response.body)
          key_data = jwks["keys"].find { |k| k["kid"] == kid }
          return JWT::JWK.import(key_data).public_key if key_data
        end
      rescue StandardError
        # Fall through to stored key
      end

      # Fallback: use stored platform public key
      if deployment.platform_public_key.present?
        return OpenSSL::PKey::RSA.new(deployment.platform_public_key)
      end

      raise SecurityError, "Could not obtain platform public key"
    end
  end
end

     
