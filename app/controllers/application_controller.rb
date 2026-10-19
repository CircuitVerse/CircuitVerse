# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include SearchHelper

  protect_from_forgery with: :exception

  before_action :store_user_location!, if: :storable_location?
  before_action :set_notifications, if: :current_user
  before_action :prepare_search_data
  around_action :switch_locale

  after_action :verify_authorized, unless: :skip_authorization_verification?

  rescue_from Pundit::NotAuthorizedError, with: :auth_error
  rescue_from ApplicationPolicy::CustomAuthException, with: :custom_auth_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def auth_error
    render plain: "You are not authorized to do the requested operation", status: :forbidden
  end

  def custom_auth_error(exception)
    render plain: "Not Authorized: #{exception.custom_message}", status: :forbidden
  end

  def not_found
    render "errors/not_found", status: :not_found
  end

  # Around action to set the current I18n locale for the request.
  # Checks params[:locale], current_user.locale, or the Accept-Language header,
  # falling back to I18n.default_locale if none match an available locale.
  #
  # @yield Block executed in the context of the determined locale.
  # @return [Object] Result of yielding to the block.
  def switch_locale(&)
    logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    locale = params.permit(:locale)[:locale]&.to_sym || current_user&.locale&.to_sym ||
             extract_locale_from_accept_language_header
    locale = I18n.default_locale unless I18n.available_locales.include?(locale)
    logger.debug "* Locale set to '#{locale}'"
    I18n.with_locale(locale, &)
  end

  # Overrides Devise::Controller::StoreLocation.store_location_for to check if
  # URL is too long to store in the session
  def store_location_for(resource_or_scope, location)
    max_location_size = 200 # bytes
    if location && location.length > max_location_size
      super(resource_or_scope, "/")
    else
      super
    end
  end

  private

    # Engine controllers and Devise inherit from ApplicationController but
    # manage their own access control.
    #
    # @return [Boolean] true if current controller is a Devise controller, false otherwise.
    def skip_authorization_verification?
      devise_controller?
    end

    # Extracts the highest-priority supported locale from the Accept-Language HTTP request header.
    # Parses language tags case-insensitively, accounts for optional quality values,
    # and returns the first matching available locale symbol.
    #
    # @return [Symbol, nil] The matched locale symbol, or nil if missing or unsupported.
    def extract_locale_from_accept_language_header
      header = request.env["HTTP_ACCEPT_LANGUAGE"]
      return if header.blank?

      header.downcase.split(",").each_with_index.filter_map do |entry, index|
        tag, q_part = entry.split(";", 2)
        next if tag.blank?

        primary_tag = tag.strip.split(/[-_]/).first&.to_sym
        next if primary_tag.blank?

        q = q_part.to_s[/q=([\d.]+)/, 1]&.to_f || 1.0
        next if q <= 0

        [primary_tag, q, index]
      end.sort_by { |_lang, q, index| [-q, index] }.find do |lang, _q, _index|
        I18n.available_locales.include?(lang)
      end&.first
    end

    def set_notifications
      @unread = NoticedNotification.where(recipient: current_user).unread
      @notification = NoticedNotification.where(recipient: current_user).newest_first.limit(5)
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

    def prepare_search_data
      @search_countries = countries_for_search_filters(request)
      @current_filters = {
        "country" => params[:country],
        "institute" => params[:institute],
        "tag" => params[:tag]
      }
    end
end
