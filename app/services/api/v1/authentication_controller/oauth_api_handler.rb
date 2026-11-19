# frozen_string_literal: true

class Api::V1::AuthenticationController
  class OauthApiHandler
    include CustomErrors

    # @param [String] access_token
    # @param [String] provider
    def initialize(access_token, provider)
      @access_token = access_token
      @provider = provider
    end

    # @return [Hash]
    def oauth_user
      case @provider
      when "google" then google_user
      when "facebook" then facebook_user
      when "github" then github_user
      else
        raise UnsupportedOAuthProvider
      end

      # raise Invalid Access Token exception if status is 4XX
      raise InvalidOAuthToken if @response.status.client_error?

      # returns oauth user profile response if status is 2XX
      parsed_response if @response.status.success?
    end

    private

      def google_user
        # @type [HTTP::Response]
        @response = HTTP.auth("Bearer #{@access_token}")
                        .get("https://www.googleapis.com/oauth2/v3/userinfo")
      end

      def facebook_user
        validate_facebook_token!

        # @type [HTTP::Response]
        @response = HTTP.auth("Bearer #{@access_token}")
                        .get("https://graph.facebook.com/v19.0/me",
                             params: { fields: "id,name,email" })
      end

      def validate_facebook_token!
        app_id = ENV["FACEBOOK_CLIENT_ID"]
        app_secret = ENV["FACEBOOK_CLIENT_SECRET"]
        app_access_token = "#{app_id}|#{app_secret}"

        debug_response = HTTP.get(
          "https://graph.facebook.com/debug_token",
          params: { input_token: @access_token, access_token: app_access_token }
        )

        raise InvalidOAuthToken unless debug_response.status.success?

        data = JSON.parse(debug_response.body.to_s).dig("data")
        raise InvalidOAuthToken unless data&.fetch("is_valid", false) && data["app_id"] == app_id
      end

      def github_user
        # @type [HTTP::Response]
        @response = HTTP.auth("token #{@access_token}")
                        .get("https://api.github.com/user")
      end

      # @return [Hash]
      def parsed_response
        JSON.parse(@response.body.to_s)
      end
  end
end
