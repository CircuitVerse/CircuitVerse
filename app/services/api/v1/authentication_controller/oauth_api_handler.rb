# frozen_string_literal: true

class Api::V1::AuthenticationController
  class OauthApiHandler
    include CustomErrors

    def initialize(access_token, provider)
      @access_token = access_token
      @provider = provider
    end

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
      return parsed_response if @response.status.success?
    end

    private

      def google_user
        @response = HTTP.auth("Bearer #{@access_token}")
                        .get("https://www.googleapis.com/oauth2/v3/userinfo")
      end

      def facebook_user
        @response = HTTP.get("https://graph.facebook.com/v2.12/me"\
          "?fields=name,email&access_token=#{@access_token}")
      end

      def github_user
        @response = HTTP.auth("token #{@access_token}")
                        .get("https://api.github.com/user")
      end

      def parsed_response
        JSON.parse(@response.body.to_s)
      end
  end
end
