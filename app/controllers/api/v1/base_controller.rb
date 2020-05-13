# frozen_string_literal: true

class Api::V1::BaseController < ActionController::API
  include Pundit
  include CustomErrors

  DEFAULT_PER_PAGE = 5

  rescue_from ActionController::ParameterMissing do
    api_error(status: 400, errors: "invalid parameters")
  end

  rescue_from Pundit::NotAuthorizedError do
    unauthorized!
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
    header = header.split(" ").last if header
    begin
      @decoded = JsonWebToken.decode(header)[0]
      @current_user = User.find(@decoded["user_id"])
    rescue JWT::DecodeError => e
      api_error(status: 401, errors: e.message)
    end
  end

  def authenticate_user!
    authenticate_user || UnauthenticatedError
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
      page: params[:page] || 1, per_page: params[:per_page] || DEFAULT_PER_PAGE
    )
  end

  def meta_attributes(resource, extra_meta = {})
    meta = {
      current_page: resource.current_page,
      next_page: resource.next_page,
      prev_page: resource.previous_page,
      total_pages: resource.total_pages,
      total_count: resource.total_entries
    }.merge(extra_meta)

    meta
  end

  def api_error(status: 500, errors: [])
    render json: Api::V1::ErrorSerializer.new(status, errors).as_json,
      status: status
  end
end
