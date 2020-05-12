# frozen_string_literal: true

class Api::V1::AuthenticationController < Api::V1::BaseController
  before_action :authenticate_user!, except: [:login, :signup]

  # POST /auth/login
  def login
    @user = User.find_by!(email: params[:email])
    if @user&.valid_password?(params[:password])
      exp = (Time.zone.today + 365)
      token = JsonWebToken.encode(
        user: { user_id: @user.id, username: @user.name, email: @user.email },
        exp: exp
      )
      render json: {
        token: token
      }, status: :accepted
    elsif @user
      api_error(status: 401, errors: "invalid credentials")
    end
  end

  # POST /auth/signup
  def signup
    if User.exists?(email: params[:email])
      api_error(status: 409, errors: "user already exists")
    else
      @user = User.create!(signup_params)
      exp = (Time.zone.today + 365)
      token = JsonWebToken.encode(
        user: { user_id: @user.id, username: @user.name, email: @user.email },
        exp: exp
      )
      render json: { token: token }, status: :created
    end
  end

  private

    def login_params
      params.permit(:email, :password)
    end

    def signup_params
      params.permit(:name, :email, :password)
    end
end
