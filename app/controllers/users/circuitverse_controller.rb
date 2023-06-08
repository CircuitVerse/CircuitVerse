# frozen_string_literal: true

class Users::CircuitverseController < ApplicationController
  TYPEAHEAD_INSTITUTE_LIMIT = 50

  include UsersCircuitverseHelper

  before_action :authenticate_user!, only: %i[edit update groups]
  before_action :set_user, except: [:typeahead_educational_institute]
  before_action :remove_previous_avatar, only: [:update]
  after_action :attach_avatar, only: [:update]

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
    @groups_owned = Group.where(id: Group.joins(:primary_mentor).where(primary_mentor: @user))
                         .select("groups.*, COUNT(group_members.id) as group_member_count")
                         .left_outer_joins(:group_members)
                         .group("groups.id")
  end

  private

    def profile_params
      params.require(:user).permit(:name, :profile_picture, :country, :educational_institute,
                                   :subscribed, :locale, :remove_picture, :avatar)
    end

    def set_user
      @profile = current_user
      @user = User.find(params[:id])
    end

    def attach_avatar
      return if no_attachment?

      pic_exists = params[:user][:profile_picture].present? && @profile.profile_picture.present?
      @profile.avatar.attach(io: File.open(@profile.profile_picture.path), filename: "avatar.jpeg") if pic_exists
    end

    def remove_previous_avatar
      @profile.avatar.purge if params[:user][:profile_picture].present? && @profile.avatar.attached?
    end

    def no_attachment?
      @profile.remove_picture == "1" || @profile.profile_picture.blank?
    end
end
