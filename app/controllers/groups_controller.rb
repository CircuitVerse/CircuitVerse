# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :check_show_access, only: %i[show edit update destroy]
  before_action :check_edit_access, only: %i[edit update destroy]

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
    if !@group.has_valid_token?
      @group.reset_group_token
    end
  end

  def group_invite
    @group = Group.find(params[:id])
    if Group.with_valid_token.where(group_token: params[:token]).exists?
      if GroupMember.where(group_id: @group, user_id: current_user.id).exists?
        redirect_to group_path(@group), notice: "Member is already present in the group."
      else
        GroupMember.where(group_id: @group, user_id: current_user.id).first_or_create
        redirect_to group_path(@group), notice: "Group member was successfully added."
      end
    elsif Group.where(group_token: params[:token]).exists?
      redirect_to group_path(@group), notice: "Url is expired, request a new one from owner of the group."
    else
      redirect_to group_path(@group), notice: "Invalid url"
    end
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
    @group = current_user.groups_mentored.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: "Group was successfully created." }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
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
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to user_groups_path(current_user), notice: "Group was successfully deleted." }
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
      params.require(:group).permit(:name, :mentor_id)
    end

    def check_show_access
      authorize @group, :show_access?
    end

    def check_edit_access
      authorize @group, :admin_access?
    end
end
