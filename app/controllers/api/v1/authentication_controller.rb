# frozen_string_literal: true

class Api::V1::AuthenticationController < Api::V1::BaseController
  before_action :set_oauth_user, only: %i[oauth_signup oauth_login]
  before_action :check_signup_feature, only: %i[signup oauth_signup]

  # POST api/v1/auth/login
  def login
    @user = User.find_by!(email: params[:email])
    if @user&.valid_password?(params[:password])
      token = JsonWebToken.encode(
        user_id: @user.id, username: @user.name, email: @user.email
      )
      render json: { token: token }, status: :accepted
    elsif @user
      api_error(status: 401, errors: "invalid credentials")
    end
  end

  # POST api/v1/auth/signup
  def signup
    if User.exists?(email: params[:email])
      api_error(status: 409, errors: "user already exists")
    else
      @user = User.create!(signup_params)
      token = JsonWebToken.encode(
        user_id: @user.id, username: @user.name, email: @user.email
      )
      render json: { token: token }, status: :created
    end
  end

  # POST api/v1/oauth/login
  def oauth_login
    @user = User.find_by!(email: @oauth_user["email"])
    token = JsonWebToken.encode(
      user_id: @user.id, username: @user.name, email: @user.email
    )
    render json: { token: token }, status: :accepted
  end

  # POST api/v1/oauth/signup
  def oauth_signup
    if User.exists?(email: @oauth_user["email"])
      api_error(status: 409, errors: "user already exists")
    else
      @user = User.from_oauth(@oauth_user, params[:provider])
      if @user.errors.any?
        # @user has validation errors
        api_error(status: 422, errors: @user.errors)
      else
        token = JsonWebToken.encode(
          user_id: @user.id, username: @user.name, email: @user.email
        )
        render json: { token: token }, status: :created
      end
    end
  end

  # POST api/v1/forgot_password
  def forgot_password
    @user = User.find_by!(email: params[:email])
    # sends reset password instructions to the user's mail if exists
    @user.send_reset_password_instructions
    render json: { message: "password reset instructions sent to #{@user.email}" }
  end

  # GET /public_key.pem
  def public_key
    public_key = Rails.root.join("config", "public.pem").open("r:UTF-8")
    send_file public_key
  end

  private

    def set_oauth_user
      @oauth_user = OauthApiHandler.new(params[:access_token], params[:provider]).oauth_user
    end

    def login_params
      params.permit(:email, :password)
    end

    def signup_params
      params.permit(:name, :email, :password)
    end

    def oauth_params
      params.permit(:access_token, :provider)
    end

    def check_signup_feature
      return if Flipper.enabled?(:signup)

      api_error(status: 403, errors: "Signup is currently disabled.")
    end
end
