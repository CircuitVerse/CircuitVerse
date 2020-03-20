class Api::V0::BaseController < ActionController::API
  include Pundit

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def render_unprocessable_entity_response(exception)
    render json: {
      message: "Validation Failed",
      errors: ValidationErrorsSerializer.new(exception.record).serialize
    }, status: :unprocessable_entity
  end

  def render_not_found_response
    render json: { message: "Not found", code: "not_found" }, status: :not_found
  end

  def render_error_response(exception)
    render json: { message: exception.message, code: exception.code }, status: exception.http_status
  end

end
