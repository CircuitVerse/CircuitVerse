# frozen_string_literal: true

class Contests::Submissions::VotesController < ApplicationController
  skip_after_action :verify_authorized

  before_action :authenticate_user!
  before_action :set_contest_and_submission

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
      @contest = Contest.find(params.expect(:contest_id))
      @submission = @contest.submissions.find(params.expect(:submission_id))
    end
end
