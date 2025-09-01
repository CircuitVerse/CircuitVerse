# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests::Submissions#create happy path", type: :request do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest, status: :live) }
  let(:project) { create(:project, author: user) }

  before { sign_in user; enable_contests! }

  it "creates a submission and redirects with a notice" do
    expect do
      post contest_submissions_path(contest),
           params: { submission: { project_id: project.id } }
    end.to change(Submission, :count).by(1)

    expect(response).to redirect_to(contest_path(contest))
    expect(flash[:notice]).to match(/successfully added/i)
  end
end
