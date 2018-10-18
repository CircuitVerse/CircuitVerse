class Users::LogixController < ApplicationController
  before_action :authenticate_user! ,only: [:edit, :update, :groups]
  def index
    @user = User.find(params[:id])
    @edit_access = (user_signed_in? and current_user.id == @user.id)
  end
  def favourites
    @user = User.find(params[:id])
    @projects = @user.rated_projects
  end
  def profile
    @profile = User.find(params[:id])
  end
  def edit
    @profile = current_user
  end
  def update
    @profile = current_user
    @profile.name = params["profile"]["name"]
    if params["profile"]["profile_picture"]!=nil
      @profile.profile_picture = params["profile"]["profile_picture"]
    end
    @profile.save
    redirect_to profile_path(current_user)
  end
  def groups
  end
end
