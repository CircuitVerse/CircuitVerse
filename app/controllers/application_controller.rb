class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :auth_error
  rescue_from ApplicationPolicy::CustomAuthException, with: :custom_auth_error

  def auth_error
    render plain: 'You are not authorized to do the requested operation'
  end

  def custom_auth_error(exception)
    render plain: "Not Authorized: #{exception.custom_message}"
  end
end
