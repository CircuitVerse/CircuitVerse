# frozen_string_literal: true

class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :set_user, only: [:index]
  before_action :authenticate_user!
  before_action :check_access, only: [:update]

  def index
    @users = paginate(User.all)
    @options = {}
    @options[:meta] = meta_attributes(@users)
    render json: Api::V1::UserSerializer.new(
      @users, @options
    ).serialized_json
  end

  def show
    render json: Api::V1::UserSerializer.new(@user).serialized_json
  end

  def update
    @user.update!(user_params)
    if @user.update(user_params)
      render json: Api::V1::UserSerializer.new(
        @user
      ), status: :accepted
    else
      invalid_resource!(@user.errors)
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def check_access
      authorize @user, :edit?
    end

    def user_params
      params.permit(:name, :educational_institute, :country, :subscribed)
    end
end
