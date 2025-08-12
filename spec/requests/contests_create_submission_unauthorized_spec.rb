# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests::Submissions#create unauthorized project", type: :request do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest, status: :live) }
  let(:foreign_project) { create(:project) }

  before { sign_in user; enable_contests! }

  it "redirects with an alert when the project is not owned by the user" do
    post contest_submissions_path(contest),
         params: { submission: { project_id: foreign_project.id } }

    expect(response).to redirect_to(contest_path(contest))
    expect(flash[:alert]).to match(/someone else/i)
  end
end
