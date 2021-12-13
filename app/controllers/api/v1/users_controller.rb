# frozen_string_literal: true

class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: %i[show update]
  before_action :authenticate_user!
  before_action :check_access, only: [:update]
  before_action :set_details_access, except: %i[index me]

  # GET api/v1/users
  def index
    @users = paginate(User.all)
    @options = { params: { only_name: true } }
    @options[:links] = link_attrs(@users, api_v1_users_url)
    render json: Api::V1::UserSerializer.new(@users, @options)
  end

  # GET api/v1/users/:id
  def show
    render json: Api::V1::UserSerializer.new(@user, @options)
  end

  # GET api/v1/me
  def me
    @options = { params: { has_details_access: true } }
    render json: Api::V1::UserSerializer.new(current_user, @options)
  end

  # PATCH api/v1/users/:id
  def update
    @user.update!(user_params)
    if @user.update(user_params)
      render json: Api::V1::UserSerializer.new(@user, @options), status: :accepted
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

    def set_details_access
      @options = { params: { has_details_access: @user.eql?(current_user) } }
    end

    def user_params
      params.permit(:name, :locale, :educational_institute, :country, :subscribed)
    end
end
