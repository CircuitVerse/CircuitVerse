class Users::LogixController < ApplicationController
  before_action :authenticate_user! ,only: [:edit, :update, :groups]
  before_action :set_user

  def index
    @edit_access = (user_signed_in? and current_user.id == @user.id)
  end

  def favourites
    @projects = @user.rated_projects
  end

  def profile

  end

  def edit

  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path(current_user)
    else
      render :edit
    end
  end

  def groups
  end

  def profile_params
    params.require(:user).permit(:name,:profile_picture,:country,:educational_institute)
  end

  def set_user
    if current_user
      @profile = current_user
      @user = current_user
    else
      redirect_to '/users/sign_in', alert: "Please Sign In or Sign Up to continue"
    end
  end
end
