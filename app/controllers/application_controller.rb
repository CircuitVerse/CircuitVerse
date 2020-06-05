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
    render plain: "The record you wish access could not be found"
  end

  around_action :switch_locale

  def switch_locale(&action)
    if user_signed_in?
      locale = current_user.try(:language)
    else
      locale = params[:locale] || session[:locale]
      session[:locale] = locale
    end
    I18n.with_locale(locale, &action)
  end
end
