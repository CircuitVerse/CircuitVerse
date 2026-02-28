# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy group_invite generate_token]
  before_action :authenticate_user!
  before_action :check_show_access, only: %i[show edit update destroy]
  before_action :check_edit_access, only: %i[edit update destroy generate_token]

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
    @group = Group.find(params[:id])
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
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit; end

  # POST /groups
  # POST /groups.json
  def create
    @group = current_user.groups_owned.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: "Group was successfully created." }
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
    @group.destroy
    respond_to do |format|
      format.html do
        redirect_to user_groups_path(current_user), notice: "Group was successfully deleted."
      end
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.expect(group: %i[name primary_mentor_id])
    end

    def check_show_access
      authorize @group, :show_access?
    end

    def check_edit_access
      authorize @group, :admin_access?
    end
end
