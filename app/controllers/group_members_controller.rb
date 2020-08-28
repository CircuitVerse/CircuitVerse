# frozen_string_literal: true

class GroupMembersController < ApplicationController
  before_action :set_group_member, only: %i[show edit update destroy]
  before_action :check_access, only: %i[edit update destroy]
  before_action :authenticate_user!

  # GET /group_members
  # GET /group_members.json
  # def index
  #   @group_members = GroupMember.all
  # end
  #
  # # GET /group_members/1
  # # GET /group_members/1.json
  # def show
  # end
  #
  # # GET /group_members/new
  # def new
  #   @group_member = GroupMember.new
  # end

  # GET /group_members/1/edit
  # def edit
  # end

  # POST /group_members
  # POST /group_members.json
  def create
    dummy = GroupMember.new
    dummy.group_id = group_member_params[:group_id]
    authorize dummy, :mentor?

    @group = Group.find(group_member_params[:group_id])

    group_member_emails = Utils.parse_mails(group_member_params[:emails])

    present_members = User.where(id: @group.group_members.pluck(:user_id)).pluck(:email)
    newly_added = group_member_emails - present_members

    newly_added.each do |email|
      email = email.strip
      user = User.find_by(email: email)
      if user.nil?
        PendingInvitation.where(group_id: @group.id, email: email).first_or_create
        # @group.pending_invitations.create(email:email)
      else
        GroupMember.where(group_id: @group.id, user_id: user.id).first_or_create

        # group_member = @group.group_members.new
        # group_member.user_id = user.id
        # group_member.save
      end
    end

    notice = Utils.mail_notice(group_member_params[:emails], group_member_emails, newly_added)

    respond_to do |format|
      format.html do
        redirect_to group_path(@group), notice: Utils.mail_notice(group_member_params[:emails], group_member_emails, newly_added)
      end
    end
    # redirect_to group_path(@group)
    # @group_member = GroupMember.new(group_member_params)
    #
    # respond_to do |format|
    #   if @group_member.save
    #     format.html { redirect_to group_path(@group_member.group), notice: 'Group member was successfully created.' }
    #     format.json { render :show, status: :created, location: @group_member }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @group_member.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /group_members/1
  # PATCH/PUT /group_members/1.json
  # def update
  #   respond_to do |format|
  #     if @group_member.update(group_member_params)
  #       format.html { redirect_to @group_member, notice: 'Group member was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @group_member }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @group_member.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /group_members/1
  # DELETE /group_members/1.json
  def destroy
    @group_member.destroy
    respond_to do |format|
      format.html do
        redirect_to group_path(@group_member.group),
                    notice: "Group member was successfully removed."
      end
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_group_member
      @group_member = GroupMember.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_member_params
      params.require(:group_member).permit(:group_id, :user_id, :emails)
    end

    def check_access
      authorize @group_member, :mentor?
    end
end
