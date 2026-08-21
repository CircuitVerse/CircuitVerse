# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Withdraw authorization", type: :request do
  let(:author)     { create(:user) }
  let(:project)    { create(:project, author: author) }
  let(:contest)    { create(:contest, status: :live) }
  let!(:submission) { create(:submission, contest: contest, project: project, user: author) }

  before { enable_contests! }

  it "allows the project owner to withdraw their submission" do
    sign_in author

    expect do
      delete contest_submission_path(contest, submission)
    end.to change(Submission, :count).by(-1)
  end

  it "allows a site admin to withdraw any submission" do
    sign_in create(:user, admin: true)

    expect do
      delete contest_submission_path(contest, submission)
    end.to change(Submission, :count).by(-1)
  end

  it "forbids other users from withdrawing the submission" do
    sign_in create(:user)

    expect do
      delete contest_submission_path(contest, submission)
    end.not_to change(Submission, :count)

    expect(response).to have_http_status(:forbidden)
  end
end
