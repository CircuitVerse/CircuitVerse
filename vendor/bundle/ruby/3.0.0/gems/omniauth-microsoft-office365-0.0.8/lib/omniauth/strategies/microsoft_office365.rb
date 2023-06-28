require "omniauth/strategies/oauth2"

module OmniAuth
  module Strategies
    class MicrosoftOffice365 < OmniAuth::Strategies::OAuth2
      option :name, :microsoft_office365

      DEFAULT_SCOPE="openid User.Read Contacts.Read"

      option :client_options, {
        site:          "https://login.microsoftonline.com",
        authorize_url: "/common/oauth2/v2.0/authorize",
        token_url:     "/common/oauth2/v2.0/token"
      }

      option :authorize_options, %w[scope domain_hint]

      uid { raw_info["id"] }

      info do
        {
          email:           raw_info["mail"] || raw_info["userPrincipalName"],
          display_name:    raw_info["displayName"],
          first_name:      raw_info["givenName"],
          last_name:       raw_info["surname"],
          job_title:       raw_info["jobTitle"],
          business_phones: raw_info["businessPhones"],
          mobile_phone:    raw_info["mobilePhone"],
          office_phone:    raw_info["officePhone"],
          image:           avatar_file,
        }
      end

      extra do
        {
          "raw_info" => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get("https://graph.microsoft.com/v1.0/me").parsed
      end

      def authorize_params
        super.tap do |params|
          %w[display domain_hint scope auth_type].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end

          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      private

      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end

      def avatar_file
        photo = access_token.get("https://graph.microsoft.com/v1.0/me/photo/$value")
        ext   = photo.content_type.sub("image/", "") # "image/jpeg" => "jpeg"

        Tempfile.new(["avatar", ".#{ext}"]).tap do |file|
          file.binmode
          file.write(photo.body)
          file.rewind
        end

      rescue ::OAuth2::Error => e
        if e.response.status == 404 # User has no avatar...
          return nil
        elsif e.code['code'] == 'GetUserPhoto' && e.code['message'].match('not supported')
          nil
        else
          raise
        end
      end

    end
  end
end
