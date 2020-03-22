class Api::V0::AuthenticationController < Api::V0::BaseController

  before_action :authorize_request, except: :login

  # POST /auth/login
  def login
    @user = User.find_by_email(params[:email])
    if @user&.valid_password?(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      time = (Date.today + 365)
      render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                    username: @user.name }, status: :accepted
    else
      if @user
        render json: {
          errors: [{
            message: "Incorrect Credentials",
            code: "incorrect_creds"
          }]
        }, status: :unauthorized
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  private

    def login_params
      params.permit(:email, :password)
    end

end
