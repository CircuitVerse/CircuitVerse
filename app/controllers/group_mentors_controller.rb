# frozen_string_literal: true

class GroupMentorsController < ApplicationController
  before_action :set_group_mentor, only: %i[show edit update destroy]
  before_action :check_access, only: %i[edit update destroy]
  before_action :authenticate_user!

  # GET /group_mentors
  # GET /group_mentors.json
  # def index
  #   @group_mentors = GroupMentor.all
  # end
  #
  # # GET /group_mentors/1
  # # GET /group_mentors/1.json
  # def show
  # end
  #
  # # GET /group_mentors/new
  # def new
  #   @group_member = GroupMentor.new
  # end

  # GET /group_mentors/1/edit
  # def edit
  # end

  # POST /group_mentors
  # POST /group_mentors.json
  def create
    dummy = GroupMentor.new
    dummy.group_id = group_mentor_params[:group_id]
    authorize dummy, :owner?

    @group = Group.find(group_mentor_params[:group_id])

    group_mentor_emails = Utils.parse_mails(group_mentor_params[:emails])

    present_mentors = User.where(id: @group.group_mentors.pluck(:user_id)).pluck(:email)
    newly_added = group_mentor_emails - present_mentors

    newly_added.each do |email|
      email = email.strip
      user = User.find_by(email: email)
      if user.nil?
        PendingInvitation.where(group_id: @group.id, email: email).first_or_create
      else
        GroupMentor.where(group_id: @group.id, user_id: user.id).first_or_create
      end
    end

    notice = Utils.mail_notice(group_mentor_params[:emails], group_mentor_emails, newly_added)

    respond_to do |format|
      format.html do
        redirect_to group_path(@group), notice: Utils.mail_notice(group_mentor_params[:emails], group_mentor_emails, newly_added)
      end
    end
  end

  # DELETE /group_mentors/1
  # DELETE /group_mentors/1.json
  def destroy
    @group_mentor.destroy
    respond_to do |format|
      format.html do
        redirect_to group_path(@group_mentor.group),
                    notice: "Group mentor was successfully removed."
      end
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_group_mentor
      @group_mentor = GroupMentor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_mentor_params
      params.require(:group_mentor).permit(:group_id, :user_id, :emails)
    end

    def check_access
      authorize @group_mentor, :owner?
    end
end
