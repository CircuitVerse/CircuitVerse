# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, only: :launch # for lti integration
  before_action :store_user_location!, if: :storable_location?
  around_action :switch_locale

  rescue_from Pundit::NotAuthorizedError, with: :auth_error
  rescue_from ApplicationPolicy::CustomAuthException, with: :custom_auth_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def auth_error
    render plain: "You are not authorized to do the requested operation"
  end

  def custom_auth_error(exception)
    render plain: "Not Authorized: #{exception.custom_message}", status: :forbidden
  end

  def not_found
    render "errors/not_found.html.erb", status: :not_found
  end

  def switch_locale(&action)
    logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    locale = current_user&.locale || extract_locale_from_accept_language_header || I18n.default_locale
    logger.debug "* Locale set to '#{locale}'"
    begin
      I18n.with_locale(locale, &action)
    rescue I18n::InvalidLocale
      locale = I18n.default_locale
      retry
    end
  end

  private

    def extract_locale_from_accept_language_header
      request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first
    end

    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
    end

    def store_user_location!
      store_location_for(:user, request.fullpath)
    end

    def after_sign_in_path_for(resource_or_scope)
      stored_location_for(resource_or_scope) || super
    end
end
