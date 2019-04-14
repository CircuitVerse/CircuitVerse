# frozen_string_literal: true

# common utilities for specs
module SpecUtils
  def check_auth_exception(policy, action)
    expect do
      policy.public_send("#{action}?")
    end.to raise_error(ApplicationPolicy::CustomAuthException)
  end

  def not_authorized_check
    expect(response.body).to eq("You are not authorized to do the requested operation")
  end

  # A general function for authorization checks
  # request_params = [{
  #   url: "url",
  #   type: "get",
  #   params: {}
  # }, ...]
  def authorization_checks(request_params)
    request_params.each do |req|
      eval("#{req[:type]} '#{req[:url]}', params: #{req[:params] || {}}")
      not_authorized_check
    end
  end
end
