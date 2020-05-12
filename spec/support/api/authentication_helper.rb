# frozen_string_literal: true

module AuthenticationHelper
  def get_auth_token(user)
    token = JsonWebToken.encode(
      user: { user_id: user.id, username: user.name, email: user.email }
    )
    token
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end
