# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests::Submissions#create save failure", type: :request do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest, status: :live) }
  let(:project) { create(:project, author: user) }

  before { sign_in user; enable_contests! }

  it "re-renders the new_submission form with 422 when save fails" do
    allow(Submission).to receive(:new).and_wrap_original do |m, *args, **kwargs|
      submission = m.call(*args, **kwargs)
      allow(submission).to receive(:save).and_return(false)
      submission
    end

    post contest_submissions_path(contest),
         params: { submission: { project_id: project.id } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("contest-submission-button")
  end
end
