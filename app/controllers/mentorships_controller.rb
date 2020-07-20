# frozen_string_literal: true

class MentorshipsController < ApplicationController
  before_action :set_mentorship, only: %i[destroy]

  def self.policy_class
    GroupPolicy
  end

  # POST /mentorships
  # POST /mentorships.json
  def create
    @group = Group.find(mentorship_params[:group_id])
    authorize @group, :check_edit_access?
    already_present = User.where(id: @group.mentorships.pluck(:user_id)).pluck(:email)
    mentorship_emails = Utils.parse_mails_except_current_user(
                         mentorship_params[:emails],
                         current_user
                     )

    newly_added = mentorship_emails - already_present
    newly_added.each do |email|
      email = email.strip
      user = User.find_by(email: email)
      unless user.nil?
        Mentorship.where(group_id: @group.id, user_id: user.id).first_or_create
      end
    end

    notice = Utils.mail_notice(mentorship_params[:emails], mentorship_emails, newly_added)
    if mentorship_params[:emails].include?(current_user.email)
      notice.prepend("You can't invite yourself.")
    end

    respond_to do |format|
      format.html { redirect_to group_path(@group), notice: notice }
    end
  end

  # DELETE /mentorships/1
  # DELETE /mentorships/1.json
  def destroy
    authorize @mentorship.group, :check_edit_access?

    @mentorship.destroy
    respond_to do |format|
    format.html {
                  redirect_to group_path(@group),
                  notice: "Mentorship relation was successfully destroyed."
                }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_mentorship
      @mentorship = Mentorship.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mentorship_params
      params.require(:mentorship).permit(:user_id, :group_id, :emails)
    end
end
