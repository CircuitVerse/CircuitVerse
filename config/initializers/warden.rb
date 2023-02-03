# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  Warden::Strategies.add(:jwt_token, JwtTokenStrategy)
end
