# frozen_string_literal: true

class Users::CircuitverseController < ApplicationController
  TYPEAHEAD_INSTITUTE_LIMIT = 50

  include UsersCircuitverseHelper

  before_action :authenticate_user!, only: %i[edit update groups destroy]
  before_action :set_user, except: [:typeahead_educational_institute]
  before_action :remove_previous_profile_picture, only: [:update]
  before_action :authorize_user_deletion, only: [:destroy]

  def index
    @profile = ProfileDecorator.new(@user)
    @projects = @user.rated_projects.with_attached_circuit_preview
    @user_projects = @user.projects.with_attached_circuit_preview
    @collaborated_projects = @user.collaborated_projects.with_attached_circuit_preview
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

  def destroy
    @user.destroy!
    redirect_to root_path, status: :see_other, notice: t("users.circuitverse.account_deleted")
  rescue StandardError => e
    Rails.logger.error("User deletion failed for user #{@user.id}: #{e.message}")
    redirect_to profile_edit_path(@user), alert: t("users.circuitverse.error_deleting_account")
  end

  private

    def profile_params
      params.expect(user: %i[name profile_picture country educational_institute
                             subscribed locale remove_picture avatar vuesim])
    end

    def set_user
      @profile = current_user
      @user = User.find(params[:id])
    end

    def remove_previous_profile_picture
      @profile.profile_picture.purge if params[:user][:profile_picture].present? && @profile.profile_picture.attached?
    end

    def authorize_user_deletion
      # Safety check: Only allow users to delete their own account
      return if current_user.id == @user.id

      redirect_to profile_path(@user), alert: t("users.circuitverse.unauthorized_deletion")
    end
end
