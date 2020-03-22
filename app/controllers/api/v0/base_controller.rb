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

  def paginate(resource)
      default_per_page = Rails.application.secrets.default_per_page || 3

      resource.paginate({
        page: params[:page] || 1, per_page: params[:per_page] || default_per_page
      })
    end

    #expects paginated resource!
    def meta_attributes(resource, extra_meta = {})

      meta = {
        current_page: resource.current_page,
        next_page: resource.next_page,
        prev_page: resource.previous_page,
        total_pages: resource.total_pages,
        total_count: resource.total_entries
      }.merge(extra_meta)

      return meta
    end

end
