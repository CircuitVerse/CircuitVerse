# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests#create_submission edge cases", type: :request do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest, status: :live) }
  let(:project) { create(:project, author: user) }

  before { sign_in user; enable_contests! }

  it "rejects a second submission of the same project" do
    2.times do
      post create_submission_path(contest),
           params: { contest_id: contest.id,
                     submission: { project_id: project.id } }
    end

    expect(response).to redirect_to(new_submission_path(contest))
  end

  it "rejects a project the user does not own" do
    foreign_project = create(:project)

    post create_submission_path(contest),
         params: { contest_id: contest.id,
                   submission: { project_id: foreign_project.id } }

    expect(response).to redirect_to(contest_page_path(contest))
    expect(flash[:alert]).to match(/someone else’s project/i)
  end
end
