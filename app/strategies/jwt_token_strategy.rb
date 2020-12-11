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
      env["HTTP_AUTHORIZATION"].to_s.remove("Token ")
    end
end
