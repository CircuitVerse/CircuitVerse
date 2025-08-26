# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Withdraw guard", type: :request do
  it "does not allow withdrawing after contest completion" do
    author     = create(:user)
    project    = create(:project, author: author)
    contest    = create(:contest, status: :completed)
    submission = create(:submission, contest: contest, project: project)

    sign_in author

    expect do
      delete contest_submission_path(contest, submission)
    end.not_to change(Submission, :count)

    expect(response).to redirect_to(contest_path(contest))
    expect(flash[:alert]).to eq("Withdrawals are closed as the contest has ended.")
  end
end
