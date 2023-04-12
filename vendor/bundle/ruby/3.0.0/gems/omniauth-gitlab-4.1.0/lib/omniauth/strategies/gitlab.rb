
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class GitLab < OmniAuth::Strategies::OAuth2
      option :client_options, site: 'https://gitlab.com'

      option :redirect_url

      uid { raw_info['id'].to_s }

      info do
        {
          name: raw_info['name'],
          username: raw_info['username'],
          email: raw_info['email'],
          image: raw_info['avatar_url']
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('api/v4/user').parsed
      end

      def callback_url
        options.redirect_url || (full_host + callback_path)
      end
    end
  end
end

OmniAuth.config.add_camelization 'gitlab', 'GitLab'
