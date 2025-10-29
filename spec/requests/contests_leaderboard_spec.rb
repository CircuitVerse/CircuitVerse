# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests Leaderboard", type: :request do
  it "renders when contest is live" do
    contest = create(:contest, status: :live)
    get leaderboard_contest_path(contest)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t!("contest.leaderboard.title", id: contest.id))
  end

  it "renders when contest is completed" do
    contest = create(:contest, status: :completed)
    get leaderboard_contest_path(contest)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t!("contest.leaderboard.title", id: contest.id))
  end
end
