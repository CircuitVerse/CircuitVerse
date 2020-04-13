class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  before_action :store_user_location!, if: :storable_location?

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

  private

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
