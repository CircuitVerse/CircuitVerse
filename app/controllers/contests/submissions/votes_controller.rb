# frozen_string_literal: true

class Contests::Submissions::VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contest_and_submission
  before_action :check_contests_feature_flag

  def create
    return redirect_to contest_path(@contest), alert: t(".voting_closed") if @contest.completed?

    notice = handle_vote_creation
    redirect_to contest_path(@contest), notice: notice
  end

  private

    def set_contest_and_submission
      @contest = Contest.find(params[:contest_id])
      @submission = @contest.submissions.find(params[:submission_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to contests_path, alert: t("contest_or_submission_not_found")
    end

    def check_contests_feature_flag
      redirect_to root_path, alert: t("feature_not_available") unless Flipper.enabled?(:contests, current_user)
    end

    def handle_vote_creation
      user_votes = current_user.votes_for_contest(@contest.id)

      if user_votes >= SubmissionVote::USER_VOTES_PER_CONTEST
        return t(".all_votes_used")
      elsif SubmissionVote.exists?(user_id: current_user.id, submission_id: @submission.id)
        return t(".already_voted")
      else
        begin
          SubmissionVote.create!(user_id: current_user.id, submission_id: @submission.id, contest_id: @contest.id)
          t(".success", votes_remaining: SubmissionVote::USER_VOTES_PER_CONTEST - 1 - user_votes)
        rescue ActiveRecord::RecordInvalid
          t(".vote_failed", default: "Failed to record vote.")
        end
      end
    end
end
