# frozen_string_literal: true

class Users::CircuitverseController < ApplicationController
  TYPEAHEAD_INSTITUTE_LIMIT = 50

  include UsersCircuitverseHelper

  before_action :authenticate_user!, only: %i[edit update groups]
  before_action :set_user, except: [:typeahead_educational_institute]

  def index
    @profile = ProfileDecorator.new(@user)
    @projects = @user.rated_projects
  end

  def edit; end

  def typeahead_educational_institute
    query = params[:query]
    institute_list = User.where("educational_institute LIKE :query", query: "%#{query}%")
                         .distinct
                         .limit(TYPEAHEAD_INSTITUTE_LIMIT)
                         .pluck(:educational_institute)
    typeahead_array = institute_list.map { |item| { name: item } }
    render json: typeahead_array
  end

  def update
    if @profile.update(profile_params)
      redirect_to user_projects_path(current_user)
    else
      render :edit
    end
  end

  def groups
    @user = authorize @user
    @groups_mentored = Group.where(id: Group.joins(:mentor).where(mentor: @user))
                            .select("groups.*, COUNT(group_members.id) as group_member_count")
                            .joins("left outer join group_members on \
                              (group_members.group_id = groups.id)")
                            .group("groups.id")
  end

  private

    def profile_params
      params.require(:user).permit(:name, :profile_picture, :country, :educational_institute,
                                   :subscribed, :locale, :remove_picture)
    end

    def set_user
      @profile = current_user
      @user = User.find(params[:id])
    end
end
