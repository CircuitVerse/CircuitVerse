# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :auth_error
  rescue_from ApplicationPolicy::CustomAuthException, with: :custom_auth_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def auth_error
    render plain: "You are not authorized to do the requested operation"
  end

  def custom_auth_error(exception)
    render plain: "Not Authorized: #{exception.custom_message}"
  end

  def not_found
    render "errors/not_found.html.erb"
  end
end
