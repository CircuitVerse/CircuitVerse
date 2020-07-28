# frozen_string_literal: true

class Api::V1::AuthenticationController < Api::V1::BaseController
  before_action :oauth_profile, only: %i[oauth_signup oauth_login]

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
    @user = User.find_by!(email: @response["email"])
    token = JsonWebToken.encode(
      user_id: @user.id, username: @user.name, email: @user.email
    )
    render json: { token: token }, status: :accepted
  end

  # POST api/v1/oauth/signup
  def oauth_signup
    if User.exists?(email: @response["email"])
      api_error(status: 409, errors: "user already exists")
    else
      begin
        @user = create_oauth_user
        token = JsonWebToken.encode(
          user_id: @user.id, username: @user.name, email: @user.email
        )
        render json: { token: token }, status: :created
      rescue ActiveRecord::RecordInvalid
        api_error(status: 422, errors: @user.errors)
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
    public_key = File.open(Rails.root.join("config", "public.pem"), "r:UTF-8")
    send_file public_key
  end

  private

    # rubocop:disable Metrics/AbcSize
    def oauth_profile
      case params[:provider]
      when "google"
        @response = HTTP.auth("Bearer #{params[:access_token]}")
                        .get("https://www.googleapis.com/oauth2/v3/userinfo")
      when "facebook"
        @response = HTTP.get("https://graph.facebook.com/v2.12/me"\
          "?fields=name,email&access_token=#{params[:access_token]}")
      when "github"
        @response = HTTP.auth("token #{params[:access_token]}")
                        .get("https://api.github.com/user")
      else
        api_error(status: 404, errors: "#{params[:provider]} as a provider is not supported")
      end
      @response = JSON.parse(@response.body.to_s)
    end
    # rubocop:enable Metrics/AbcSize

    def create_oauth_user
      User.create!(
        name: @response["name"],
        email: @response["email"],
        password: Devise.friendly_token[0, 20],
        provider: params[:provider],
        uid: @response["id"] || @response["sub"]
      )
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
end
