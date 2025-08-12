# frozen_string_literal: true

require "rails_helper"

describe "Contests Leaderboard", type: :system do
  before { Flipper.enable(:contests) }

  it "shows button on completed contest and displays ordered rankings" do
    contest  = create(:contest, status: :completed)
    author_a = create(:user, name: "Alpha")
    author_b = create(:user, name: "Beta")

    p_a = create(:project, author: author_a, name: "AlphaProj")
    p_b = create(:project, author: author_b, name: "BetaProj")

    create(:submission, contest: contest, project: p_a,
                        submission_votes_count: 3, created_at: 2.hours.ago)
    create(:submission, contest: contest, project: p_b,
                        submission_votes_count: 3, created_at: 1.hour.ago)

    visit contest_path(contest)
    expect(page).to have_link(I18n.t!("contest.show.view_leaderboard"))

    click_link I18n.t!("contest.show.view_leaderboard")
    expect(page).to have_current_path(leaderboard_contest_path(contest))

    rows = page.all("tbody tr")
    expect(rows.first).to have_text("AlphaProj")
    expect(rows.last).to have_text("BetaProj")
  end

  it "does not expose leaderboard on live contest" do
    contest = create(:contest, status: :live)
    visit leaderboard_contest_path(contest)
    expect(page).to have_current_path(contest_path(contest))
    expect(page).to have_text(I18n.t!("contests.leaderboard.only_after_end"))
  end
end
