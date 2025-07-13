# frozen_string_literal: true

class Contests::Submissions::VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contest_and_submission
  before_action :check_contests_feature_flag

  def create
    redirect_to contest_path(@contest), alert: t(".voting_closed") and return if @contest.completed?

    user_votes = current_user.votes_for_contest(@contest.id)

    notice = if user_votes >= SubmissionVote::USER_VOTES_PER_CONTEST
      t(".all_votes_used")
    elsif SubmissionVote.exists?(user_id: current_user.id, submission_id: @submission.id)
      t(".already_voted")
    else
      SubmissionVote.create!(user_id: current_user.id, submission_id: @submission.id, contest_id: @contest.id)
      t(".success", votes_remaining: SubmissionVote::USER_VOTES_PER_CONTEST - 1 - user_votes)
    end

    redirect_to contest_path(@contest), notice: notice
  end

  private

    def set_contest_and_submission
      @contest = Contest.find(params[:contest_id])
      @submission = @contest.submissions.find(params[:submission_id])
    end

    def check_contests_feature_flag
      return if Flipper.enabled?(:contests, current_user)

      redirect_to root_path, alert: t("feature_not_available")
    end
end
