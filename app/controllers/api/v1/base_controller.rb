# frozen_string_literal: true

class Api::V1::BaseController < ActionController::API
  include Pundit
  include CustomErrors
  attr_reader :current_user

  DEFAULT_PER_PAGE = 5

  rescue_from ActionController::ParameterMissing do
    api_error(status: 400, errors: "invalid parameters")
  end

  rescue_from Pundit::NotAuthorizedError do
    unauthorized!
  end

  rescue_from MissingAuthHeader do
    api_error(status: 401, errors: "Authentication header is missing")
  end

  rescue_from ActiveRecord::RecordNotFound do
    api_error(status: 404, errors: "resource not found!")
  end

  rescue_from ActiveRecord::RecordInvalid do
    api_error(status: 422, errors: "resource invalid!")
  end

  rescue_from UnauthenticatedError do
    unauthenticated!
  end

  def authenticate_user
    header = request.headers["Authorization"]
    return if header.blank?

    auth_header = header.split(" ").last
    begin
      @decoded = JsonWebToken.decode(auth_header)[0]
      @current_user = User.find(@decoded["user_id"])
    rescue JWT::DecodeError => e
      api_error(status: 401, errors: e.message)
    end
  end

  def authenticate_user!
    raise MissingAuthHeader if request.headers["Authorization"].blank?

    authenticate_user
    raise UnauthenticatedError if current_user.nil?
  end

  def unauthenticated!
    api_error(status: 401, errors: "not authenticated")
  end

  def unauthorized!
    api_error(status: 403, errors: "not authorized")
  end

  def not_found!
    api_error(status: 404, errors: "resource not found")
  end

  def invalid_resource!(errors = [])
    api_error(status: 422, errors: errors)
  end

  def paginate(resource)
    resource.paginate(
      page: (params.to_unsafe_h.dig("page", "number") || 1).to_i,
      per_page: (params.to_unsafe_h.dig("page", "size") || DEFAULT_PER_PAGE).to_i
    )
  end

  def link_attrs(resource, base_url)
    {
      self: paginated_url(base_url, resource.current_page),
      first: paginated_url(base_url, 1),
      prev: paginated_url(base_url, resource.previous_page),
      next: paginated_url(base_url, resource.next_page),
      last: paginated_url(base_url, resource.total_pages)
    }
  end

  def api_error(status: 500, errors: [])
    render json: Api::V1::ErrorSerializer.new(status, errors).as_json,
           status: status
  end

  private

    def paginated_url(base_url, page)
      page ? "#{base_url}?page[number]=#{page}" : nil
    end
end
