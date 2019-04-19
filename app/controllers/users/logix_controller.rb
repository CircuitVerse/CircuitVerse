# frozen_string_literal: true

class Users::LogixController < ApplicationController
  TYPEAHEAD_INSTITUTE_LIMIT = 50
  before_action :authenticate_user!, only: [:edit, :update, :groups]
  before_action :set_user, except: [:typeahead_educational_institute]

  def index
  end

  def favourites
    @projects = @user.rated_projects
  end

  def profile
    @profile = ProfileDecorator.new(@user)
  end

  def edit
  end

  def typeahead_educational_institute
    query = params[:query]
    educational_institute_list = User.where("educational_institute LIKE :query", query:  "%#{query}%")
                                     .distinct
                                     .pluck(:educational_institute)
                                     .limit(TYPEAHEAD_INSTITUTE_LIMIT)
    typeahead_array = educational_institute_list.map { |item| { name: item } }
    render json: typeahead_array
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path(current_user)
    else
      render :edit
    end
  end

  def groups
    @user = authorize @user
  end

  private

  def profile_params
    params.require(:user).permit(:name, :profile_picture, :country, :educational_institute)
  end

  def set_user
    @profile = current_user
    @user = User.find(params[:id])
  end
end
