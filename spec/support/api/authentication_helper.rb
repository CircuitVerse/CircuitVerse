# frozen_string_literal: true

module AuthenticationHelper
  def get_auth_token(user)
    JsonWebToken.encode(
      user_id: user.id, username: user.name, email: user.email
    )
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end
