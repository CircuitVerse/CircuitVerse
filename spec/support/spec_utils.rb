# frozen_string_literal: true

# common utilities for specs
module SpecUtils
  def check_auth_exception(policy, action)
    expect do
      policy.public_send("#{action}?")
    end.to raise_error(ApplicationPolicy::CustomAuthException)
  end
end
