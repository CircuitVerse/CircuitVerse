# common utilities for specs
module SpecUtils
  def check_auth_exception(policy, action)
    expect { policy.public_send("#{action}?") }.to raise_error(ApplicationPolicy::CustomAuthException)
  end
end
