# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest::LeaderboardPageComponent, type: :component do
  it "renders the leaderboard title" do
    contest = create(:contest, status: :completed)

    render_inline described_class.new(contest: contest, submissions: [])

    expect(page).to have_text(I18n.t!("contest.leaderboard.title", id: contest.id))
  end

  it "orders submissions by votes desc then created_at asc" do
    contest  = create(:contest, status: :completed)
    author1  = create(:user, name: "Alice")
    author2  = create(:user, name: "Bob")
    project1 = create(:project, author: author1, name: "P1")
    project2 = create(:project, author: author2, name: "P2")

    s1 = create(:submission, contest: contest, project: project1,
                             submission_votes_count: 5, created_at: 1.hour.ago)
    s2 = create(:submission, contest: contest, project: project2,
                             submission_votes_count: 5, created_at: Time.current)

    render_inline described_class.new(contest: contest, submissions: [s1, s2])

    rows = page.all("tbody tr")
    expect(rows.size).to eq(2)
    expect(rows[0]).to have_text("P1")
    expect(rows[1]).to have_text("P2")
    expect(page).to have_text(I18n.t!("contest.votes_count", count: 5))
  end

  it "shows empty state when no submissions" do
    contest = create(:contest, status: :completed)
    render_inline described_class.new(contest: contest, submissions: [])
    expect(page).to have_text(I18n.t!("contest.leaderboard.no_submissions"))
  end
end
