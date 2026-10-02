# frozen_string_literal: true

class Api::V1::BaseController < ActionController::API
  include Pundit::Authorization
  include CustomErrors
  include ActionController::RequestForgeryProtection
  include ActiveStorage::SetCurrent
  include Pagy::Backend

  protect_from_forgery with: :exception, if: lambda {
    request.headers["Authorization"].blank? && current_user
  }

  after_action :verify_authorized

  DEFAULT_PER_PAGE = 9

  rescue_from ActionController::ParameterMissing do
    api_error(status: 400, errors: "invalid parameters")
  end

  rescue_from Pundit::NotAuthorizedError do
    unauthorized!
  end

  rescue_from ApplicationPolicy::CustomAuthException do |exception|
    api_error(status: 403, errors: exception.custom_message)
  end

  rescue_from InvalidOAuthToken do
    api_error(status: 401, errors: "OAuth token is invalid")
  end

  rescue_from UnsupportedOAuthProvider do
    api_error(status: 404, errors: "OAuth provider not supported")
  end

  rescue_from ActiveRecord::RecordNotFound do
    api_error(status: 404, errors: "resource not found!")
  end

  rescue_from ActiveRecord::RecordInvalid do
    api_error(status: 422, errors: "resource invalid!")
  end

  rescue_from Pundit::NotAuthorizedError do
    api_error(status: 403, errors: "not authorized for this action")
  end

  rescue_from ActionController::InvalidAuthenticityToken do
    api_error(status: 403, errors: "not authorized for this action")
  end

  def security_transgression_unless(check)
    raise Pundit::NotAuthorizedError unless check
  end

  def unauthorized!
    api_error(status: 403, errors: "not authorized")
  end

  def not_found!
    api_error(status: 404, errors: "resource not found")
  end

  def invalid_resource!(_errors = [])
    api_error(status: 422, errors: "invalid resource")
  end

  def paginate(resource)
    page = (params.to_unsafe_h.dig("page", "number") || 1).to_i
    limit = (params.to_unsafe_h.dig("page", "size") || DEFAULT_PER_PAGE).to_i
    @pagy, records = pagy(resource, page: page, limit: limit, overflow: :empty_page)
    records
  end

  def link_attrs(base_url)
    {
      self: paginated_url(base_url, @pagy.page),
      first: paginated_url(base_url, 1),
      prev: paginated_url(base_url, @pagy.prev),
      next: paginated_url(base_url, @pagy.next),
      last: paginated_url(base_url, @pagy.last)
    }
  end

  def api_error(status: 500, errors: [])
    render json: Api::V1::ErrorSerializer.new(status, errors).as_json,
           status: status
  end

  private

    def paginated_url(base_url, page)
      separator = base_url.index("?").nil? ? "?" : "&"
      "#{base_url}#{separator}page[number]=#{page}" if page
    end
end
