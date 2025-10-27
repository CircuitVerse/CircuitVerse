# frozen_string_literal: true

require "rails_helper"

RSpec.describe "contests/leaderboard.html.erb", type: :view do
  it "renders the leaderboard title and headers when submissions are present" do
    contest  = create(:contest)
    author   = create(:user, name: "Alice")
    project  = create(:project, author: author, name: "P1")
    sub      = create(:submission, contest: contest, project: project,
                                   submission_votes_count: 3, created_at: 1.hour.ago)

    assign(:contest, contest)
    assign(:submissions, [sub])

    render template: "contests/leaderboard"

    expect(rendered).to include(I18n.t!("contest.leaderboard.title", id: contest.id))
    expect(rendered).to include(I18n.t!("contest.leaderboard.columns.rank"))
    expect(rendered).to include(I18n.t!("contest.leaderboard.columns.project"))
    expect(rendered).to include(I18n.t!("contest.leaderboard.columns.author"))
    expect(rendered).to include(I18n.t!("contest.leaderboard.columns.votes"))
  end

  it "renders the empty state when there are no submissions" do
    contest = create(:contest)

    assign(:contest, contest)
    assign(:submissions, [])

    render template: "contests/leaderboard"

    expect(rendered).to include(I18n.t!("contest.leaderboard.no_submissions"))
  end
end
