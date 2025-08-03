# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests::Submissions::Votes#create edge cases", type: :request do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest, status: :completed) }
  let(:proj)    { create(:project, author: user) }
  let(:sub)     { create(:submission, contest: contest, project: proj, user: user) }

  before do
    sign_in user
    enable_contests!
  end

  it "rejects voting on completed contest" do
    post contest_submission_votes_path(contest, sub)
    expect(response).to redirect_to(contest_path(contest))
    expect(flash[:alert]).to eq("Voting is closed.")
  end

  it "rejects when user has exhausted votes" do
    live_contest = Contest.find_by(status: :live) || create(:contest, status: :live)
    other_sub    = create(:submission, contest: live_contest)

    SubmissionVote::USER_VOTES_PER_CONTEST.times do
      fresh_sub = create(:submission, contest: live_contest)
      create(:submission_vote, contest: live_contest, submission: fresh_sub, user: user)
    end

    post contest_submission_votes_path(live_contest, other_sub)
    expect(flash[:notice]).to eq("You have used all your votes!")
  end
end
