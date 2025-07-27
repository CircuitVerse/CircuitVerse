# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests#show (winner branch)", type: :request do
  let(:user)     { create(:user) }
  let(:contest)  { create(:contest, status: :completed) }
  let(:project)  { create(:project, author: user) }
  let!(:submission) { create(:submission, contest: contest, project: project, user: user) }

  before do
    create(:contest_winner, contest: contest, submission: submission, project: project)
    sign_in user
    enable_contests!
  end

  it "renders the winner’s name" do
    get contest_path(contest)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(project.name)
  end
end
