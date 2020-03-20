class Api::V0::UsersController < Api::V0::BaseController

  before_action :authorize_request

  def index
    render :json => UserSerializer.new(@current_user).serialized_json
  end

  def update
    @current_user.update(user_params)
    if @current_user.update(user_params)
      render :json => UserSerializer.new(@current_user), status: :accepted
    else
      render :json => @current_user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :educational_institute, :country, :subscribed)
  end

end

