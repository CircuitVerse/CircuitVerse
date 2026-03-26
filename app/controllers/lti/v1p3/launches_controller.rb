# frozen_string_literal: true

require "net/http"
require "json"
require "openssl"

module Lti
  module V1p3
    class LaunchesController < ApplicationController
      skip_before_action :verify_authenticity_token,
                         only: %i[oidc_login oidc_callback]
      after_action :allow_iframe_lti, only: [:oidc_callback]

      # GET /lti/v1p3/jwks
      # Serves the tool's RSA public key so platforms can
      # verify JWT signatures on client assertions.
      def jwks
        render json: { keys: [build_jwk] }
      end

      # POST /lti/v1p3/oidc/login
      # Receives OIDC login initiation from platform.
      # Validates the issuer, generates state + nonce,
      # stores both in session, redirects to platform
      # authorization endpoint.
      def oidc_login
        iss      = params[:iss]
        platform = LtiPlatform.find_by(issuer: iss)

        unless platform
          render plain: "Unknown platform: #{iss}",
                 status: :unauthorized and return
        end

        state = SecureRandom.hex(24)
        nonce = SecureRandom.hex(24)

        cookie_options = {
          same_site: :none,
          secure:    true,
          httponly:  true,
          expires:   10.minutes
        }

        cookies.signed[:lti_v1p3_state]       = cookie_options.merge(value: state)
        cookies.signed[:lti_v1p3_nonce]       = cookie_options.merge(value: nonce)
        cookies.signed[:lti_v1p3_platform_id] = cookie_options.merge(value: platform.id.to_s)

        auth_params = {
          scope:            "openid",
          response_type:    "id_token",
          response_mode:    "form_post",
          prompt:           "none",
          client_id:        platform.client_id,
          redirect_uri:     v1p3_oidc_callback_url,
          login_hint:       params[:login_hint],
          lti_message_hint: params[:lti_message_hint],
          state:            state,
          nonce:            nonce
        }.compact

        redirect_to "#{platform.auth_url}?#{auth_params.to_query}",
                    allow_other_host: true
      end

      # POST /lti/v1p3/oidc/callback
      # Receives JWT id_token from platform.
      # Validates state, decodes + verifies JWT,
      # validates nonce, sets session, renders claims.
      def oidc_callback
        id_token       = params[:id_token]
        returned_state = params[:state]
        stored_state   = cookies.signed[:lti_v1p3_state]
        stored_nonce   = cookies.signed[:lti_v1p3_nonce]
        platform_id    = cookies.signed[:lti_v1p3_platform_id]

        cookies.delete(:lti_v1p3_state)
        cookies.delete(:lti_v1p3_nonce)
        cookies.delete(:lti_v1p3_platform_id)

        unless returned_state.present? &&
               returned_state == stored_state
          render plain: "State mismatch — possible CSRF",
                 status: :unauthorized and return
        end

        platform = LtiPlatform.find_by(id: platform_id)
        unless platform
          render plain: "Platform not found",
                 status: :unauthorized and return
        end

        claims = decode_and_verify(id_token, platform)
        unless claims
          render plain: "JWT verification failed",
                 status: :unauthorized and return
        end

        unless claims["nonce"] == stored_nonce
          render plain: "Nonce mismatch",
                 status: :unauthorized and return
        end

        @claims = claims
        render :launch_success, layout: false
      end

      private

      def decode_and_verify(id_token, platform)
        # Step 1: decode header without verification to
        # get kid for JWKS lookup
        _payload, header = JWT.decode(id_token, nil, false)
        kid = header["kid"]

        # Step 2: fetch platform JWKS and find matching key
        jwks_keys = fetch_platform_jwks(platform.jwks_url)
        pub_key   = find_public_key(jwks_keys, kid)
        return nil unless pub_key

        # Step 3: decode and verify fully
        payload, _header = JWT.decode(
          id_token,
          pub_key,
          true,
          algorithms: ["RS256"],
          verify_iat: true
        )
        payload
      rescue JWT::DecodeError => e
        Rails.logger.warn("LTI 1.3 JWT decode failed: #{e.message}")
        nil
      end

      def fetch_platform_jwks(jwks_url)
        uri      = URI.parse(jwks_url)
        response = Net::HTTP.get_response(uri)
        JSON.parse(response.body)["keys"]
      rescue StandardError => e
        Rails.logger.error("Failed to fetch JWKS from #{jwks_url}: #{e.message}")
        []
      end

      def find_public_key(jwks_keys, kid)
        key_data = if kid.present?
                     jwks_keys.find { |k| k["kid"] == kid }
                   else
                     jwks_keys.first
                   end
        return nil unless key_data

        jwk = JWT::JWK.import(key_data)
        jwk.public_key
      rescue StandardError => e
        Rails.logger.error("JWK import failed: #{e.message}")
        nil
      end

      def build_jwk
        private_key_pem =
          Rails.application.credentials.lti_tool_private_key
        raise "LTI private key not configured in credentials" \
          unless private_key_pem.present?

        private_key = OpenSSL::PKey::RSA.new(private_key_pem)
        pub_key     = private_key.public_key
        kid         = Rails.application.credentials.lti_tool_kid ||
                      "circuitverse-lti-key-1"

        {
          kty: "RSA",
          use: "sig",
          alg: "RS256",
          kid: kid,
          n: Base64.urlsafe_encode64(
               pub_key.n.to_s(2), padding: false),
          e: Base64.urlsafe_encode64(
               pub_key.e.to_s(2), padding: false)
        }
      end

      def allow_iframe_lti
        response.headers.delete("X-Frame-Options")
        response.headers["Content-Security-Policy"] =
          "frame-ancestors 'self' https://saltire.lti.app"
      end
    end
  end
end
