# frozen_string_literal: true

class JwtTokenStrategy < Warden::Strategies::Base
  def valid?
    token.present?
  end

  def authenticate!
    decoded = JsonWebToken.decode(token)
    user = User.find(decoded.first["user_id"])
    if user
      success!(user)
    else
      fail!("Invalid")
    end
  rescue JWT::DecodeError => e
    fail!("Unable to decode the token #{e.message}")
  end

  private

    def token
      authorization_header_token || cookie_token
    end

    def authorization_header_token
      pattern = /^Token /
      header = env["HTTP_AUTHORIZATION"]
      header.gsub(pattern, "") if header&.match(pattern)
    end

    def cookie_token
      cvt_cookie = env["HTTP_COOKIE"]&.split("; ")&.find { |c| c.start_with?("cvt=") }
      cvt_cookie&.gsub("cvt=", "")
    end
end
