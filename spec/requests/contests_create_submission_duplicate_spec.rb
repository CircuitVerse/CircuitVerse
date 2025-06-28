# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests#create_submission duplicate protection", type: :request do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest, status: :live) }
  let(:project) { create(:project, author: user) }

  before { sign_in user; enable_contests! }

  it "rejects a second submission of the same project" do
    post create_submission_path(contest),
         params: { contest_id: contest.id,
                   submission: { project_id: project.id } }

    post create_submission_path(contest),
         params: { contest_id: contest.id,
                   submission: { project_id: project.id } }

    expect(response).to redirect_to(new_submission_path(contest))
  end
end
