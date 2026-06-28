# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy group_invite generate_token]
  before_action :authenticate_user!
  before_action :check_organizations_feature_flag, only: %i[index new create], if: lambda {
    params[:organization_id].present? || params.dig(:group, :organization_id).present?
  }
  before_action :check_show_access, only: %i[show edit update destroy]
  before_action :check_edit_access, only: %i[edit update destroy generate_token]

  # GET /organizations/:organization_id/groups
  def index
    if params[:organization_id].present?
      @organization = find_organization_by_param(params[:organization_id])
      if @organization.nil?
        redirect_to root_path, alert: "Organization not found."
        return
      end
      @groups = @organization.groups.paginate(page: params[:page], per_page: 15)
    else
      redirect_to root_path, alert: "Not found."
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group_member = @group.group_members.new
    @group.assignments.each do |assignment|
      if (assignment.status == "reopening") && (assignment.deadline < Time.zone.now)
        assignment.status = "closed"
        assignment.save
      end
    end
  end

  def generate_token
    @group = Group.find(params.expect(:id))
    @group.reset_group_token unless @group.has_valid_token?
  end

  def group_invite
    if Group.with_valid_token.exists?(group_token: params[:token])
      if current_user.groups.exists?(id: @group)
        notice = "Member is already present in the group."
      elsif current_user.id == @group.primary_mentor_id
        notice = "You cannot join this group because you are its primary mentor."
      else
        current_user.group_members.create!(group: @group)
        notice = "Group member was successfully added."
      end
    elsif Group.exists?(group_token: params[:token])
      notice = "Url is expired, request a new one from the primary mentor of the group."
    else
      notice = "Invalid url"
    end
    redirect_to group_path(@group), notice: notice
  end

  # GET /groups/new
  def new
    if params[:organization_id].present?
      organization = find_organization_by_param(params[:organization_id])
      @group = Group.new(organization_id: organization&.id)
    else
      @group = Group.new
    end
  end

  # GET /groups/1/edit
  def edit; end

  # POST /groups
  # POST /groups.json
  def create
    @group = current_user.groups_owned.new(group_params)
    return if org_group_invalid?

    respond_to do |format|
      if @group.save
        format.html { redirect_to_after_group_create }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: "Group was successfully updated." }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    organization_id = @group.organization_id
    @group.destroy
    respond_to do |format|
      format.html do
        if organization_id.present?
          redirect_to organization_path(organization_id), notice: "Group was successfully deleted."
        else
          redirect_to user_groups_path(current_user), notice: "Group was successfully deleted."
        end
      end
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params.expect(:id))
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      if action_name == "create"
        params.expect(group: %i[name primary_mentor_id organization_id])
      else
        params.expect(group: %i[name primary_mentor_id])
      end
    end

    def check_show_access
      authorize @group, :show_access?
    end

    def check_edit_access
      if @group.organization_id.present?
        authorize @group, :manage?, policy_class: OrganizationGroupPolicy
      else
        authorize @group, :admin_access?
      end
    end

    def check_organizations_feature_flag
      redirect_to root_path, alert: t("feature_not_available") unless Flipper.enabled?(:organizations, current_user)
    end

    def find_organization_by_param(param)
      Organization.friendly.find_by(slug: param) ||
        Organization.find_by(id: param)
    end

    def org_group_invalid?
      return false if @group.organization_id.blank?

      if @group.organization.nil?
        redirect_to user_groups_path(current_user), alert: "Invalid organization."
        return true
      end
      authorize @group.organization, :create_group?
      false
    end

    def redirect_to_after_group_create
      if @group.organization_id.present?
        redirect_to organization_path(@group.organization),
                    notice: "Group was successfully created within the organization."
      else
        redirect_to @group, notice: "Group was successfully created."
      end
    end
end
