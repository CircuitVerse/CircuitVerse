# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests::Submissions#create edge cases", type: :request do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest, status: :live) }
  let(:project) { create(:project, author: user) }

  before { sign_in user; enable_contests! }

  it "rejects a second submission of the same project" do
    2.times do
      post contest_submissions_path(contest),
           params: { submission: { project_id: project.id } }
    end

    expect(response).to redirect_to(new_contest_submission_path(contest))
  end

  it "rejects a project the user does not own" do
    foreign_project = create(:project)

    post contest_submissions_path(contest),
         params: { submission: { project_id: foreign_project.id } }

    expect(response).to redirect_to(contest_path(contest))
    expect(flash[:alert]).to match(/someone else's project/i)
  end
end
