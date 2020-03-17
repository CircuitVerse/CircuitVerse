class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :auth_error
  rescue_from ApplicationPolicy::CustomAuthException, with: :custom_auth_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found
    render json: { error: 'not_found' }
  end

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def auth_error
    render plain: "You are not authorized to do the requested operation"
  end

  def custom_auth_error(exception)
    render plain: "Not Authorized: #{exception.custom_message}"
  end

  def not_found
    render plain: "The record you wish access could not be found"
  end
end
