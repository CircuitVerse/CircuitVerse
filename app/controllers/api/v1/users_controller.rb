# frozen_string_literal: true

class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update]
  before_action :authenticate_user!
  before_action :check_access, only: [:update]

  def index
    @users = paginate(User.all)
    @options = {  meta: meta_attributes(@users) }
    render json: Api::V1::UsersSerializer.new(@users, @options)
  end

  def show
    render json: Api::V1::UserSerializer.new(
      @user, params: { has_email_access: @user.eql?(@current_user) })
  end

  def logged_in_user
    render json: Api::V1::UserSerializer.new(
      @current_user, params: { has_email_access: true })
  end

  def update
    @user.update!(user_params)
    if @user.update(user_params)
      render json: Api::V1::UserSerializer.new(
        @user, params: { has_email_access: @user.eql?(@current_user) }
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
