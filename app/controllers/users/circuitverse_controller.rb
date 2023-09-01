# frozen_string_literal: true

class Users::CircuitverseController < ApplicationController
  # @type [Integer]
  TYPEAHEAD_INSTITUTE_LIMIT = 50

  include UsersCircuitverseHelper

  before_action :authenticate_user!, only: %i[edit update groups]
  before_action :set_user, except: [:typeahead_educational_institute]
  before_action :remove_previous_profile_picture, only: [:update]

  def index
    # @type [ProfileDecorator]
    @profile = ProfileDecorator.new(@user)
    # @type [Array<Project>]
    @projects = @user.rated_projects
  end

  def edit; end

  def typeahead_educational_institute
    query = params[:query]
    # @type [Array<String>]
    institute_list = User.where("educational_institute LIKE :query", query: "%#{query}%")
                         .distinct
                         .limit(TYPEAHEAD_INSTITUTE_LIMIT)
                         .pluck(:educational_institute)
    # @type [Array<Hash>]
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
    # @type [Array<Group>]
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
      # @type [ProfileDecorator]
      @profile = current_user
      # @type [User]
      @user = User.find(params[:id])
    end

    def remove_previous_profile_picture
      @profile.profile_picture.purge if params[:user][:profile_picture].present? && @profile.profile_picture.attached?
    end
end
