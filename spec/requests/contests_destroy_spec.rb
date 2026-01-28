# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Contests#destroy", type: :request do
  let(:admin) { create(:user, admin: true) }

  before do
    sign_in admin
    enable_contests!
  end

  # rubocop:disable RSpec/MultipleExpectations
  it "deletes a completed contest and associated data" do
    contest    = create(:contest, status: :completed)
    submission = create(:submission, contest: contest)
    create(:submission_vote, contest: contest, submission: submission, user: create(:user))
    create(:contest_winner, contest: contest, submission: submission, project: submission.project)

    expect do
      delete admin_contest_path(contest)
    end.to change(Contest, :count).by(-1)

    expect(Submission.where(contest_id: contest.id)).to be_empty
    expect(SubmissionVote.where(contest_id: contest.id)).to be_empty
    expect(ContestWinner.where(contest_id: contest.id)).to be_empty

    expect(response).to redirect_to(admin_contests_path)
    expect(flash[:notice]).to match(/successfully deleted/i)
  end
  # rubocop:enable RSpec/MultipleExpectations
end
