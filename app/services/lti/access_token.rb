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
        return cached if cached.present?

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
          token = body["access_token"]
          raise Error, "token response carried no access_token" unless token.is_a?(String) && token.present?

          [token, cache_ttl(body["expires_in"])]
        rescue HTTP::Error, JSON::ParserError => e
          raise Error, e.message
        end

        # A platform that does not say how long its token lasts gets a request
        # per call rather than a guessed lifetime we could outlive.
        def cache_ttl(expires_in)
          seconds = expires_in.to_i
          seconds.positive? ? seconds - REFRESH_LEEWAY : 0
        end

        def grant_params(deployment, scopes, signing_key)
          { grant_type: "client_credentials",
            client_assertion_type: ASSERTION_TYPE,
            client_assertion: client_assertion(deployment, signing_key),
            scope: scope_list(scopes) }
        end

        def client_assertion(deployment, signing_key)
          now = Time.now.to_i
          JWT.encode(
            { iss: deployment.client_id, sub: deployment.client_id,
              aud: deployment.access_token_url, iat: now, exp: now + ASSERTION_TTL,
              jti: SecureRandom.hex(16) },
            signing_key, "RS256", { kid: kid_for(signing_key) }
          )
        end

        # The platform resolves kid against the JWKS we publish, so it has to be
        # derived the way Lti::KeyManager derives it. JWT::JWK uses a different
        # digest and would name a key the platform cannot find.
        def kid_for(signing_key)
          JSON::JWK.new(signing_key.public_key).thumbprint
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
