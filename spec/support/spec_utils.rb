# frozen_string_literal: true

# common utilities for specs
module SpecUtils
  def check_auth_exception(policy, action)
    expect do
      policy.public_send("#{action}?")
    end.to raise_error(ApplicationPolicy::CustomAuthException)
  end

  def check_not_authorized(response)
    expect(response.body).to eq("You are not authorized to do the requested operation")
  end

  def sign_in_random_user
    user = FactoryBot.create(:user)
    sign_in user
    user
  end
end
