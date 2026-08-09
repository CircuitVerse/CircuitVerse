# frozen_string_literal: true

module Lti
  class AccessToken
    ASSERTION_TYPE = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    ASSERTION_TTL = 300
    REFRESH_LEEWAY = 30
    TIMEOUT = 5

    class Error < StandardError; end

    class << self
      def fetch(deployment, scopes, signing_key:)
        key = cache_key(deployment, scopes)
        cached = Rails.cache.read(key)
        return cached if cached

        token, ttl = request(deployment, scopes, signing_key)
        Rails.cache.write(key, token, expires_in: ttl) if ttl.positive?
        token
      end

      private

        def request(deployment, scopes, signing_key)
          response = HTTP.timeout(TIMEOUT)
                         .post(deployment.access_token_url,
                               form: grant_params(deployment, scopes, signing_key))
          raise Error, "token request failed: #{response.status}" unless response.status.success?

          body = JSON.parse(response.body.to_s)
          [body.fetch("access_token"), body.fetch("expires_in", 3600).to_i - REFRESH_LEEWAY]
        rescue HTTP::Error, JSON::ParserError, KeyError => e
          raise Error, e.message
        end

        def grant_params(deployment, scopes, signing_key)
          { grant_type: "client_credentials",
            client_assertion_type: ASSERTION_TYPE,
            client_assertion: client_assertion(deployment, signing_key),
            scope: scope_list(scopes) }
        end

        # The platform resolves kid against the tool's published JWKS.
        def client_assertion(deployment, signing_key)
          now = Time.now.to_i
          JWT.encode(
            { iss: deployment.client_id, sub: deployment.client_id,
              aud: deployment.access_token_url, iat: now, exp: now + ASSERTION_TTL,
              jti: SecureRandom.hex(16) },
            signing_key, "RS256", { kid: JWT::JWK.new(signing_key).kid }
          )
        end

        def scope_list(scopes)
          Array(scopes).uniq.sort.join(" ")
        end

        def cache_key(deployment, scopes)
          ["lti/access_token", deployment.id, scope_list(scopes)]
        end
    end
  end
end
