# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest::CardComponent, type: :component do
  it "shows contest id, entry count and status pill for a completed contest" do
    contest = create(:contest, :completed)
    create_list(:submission, 3, contest: contest)

    render_inline described_class.new(contest: contest)

    expect(page).to have_link("Contest ##{contest.id}")
    expect(page).to have_text("Entries: 3")
    expect(page).to have_text(I18n.t("contest.status.completed"))
  end

  it "shows zero entries and live status for a contest without submissions" do
    contest = create(:contest, :live)

    render_inline described_class.new(contest: contest)

    expect(page).to have_link("Contest ##{contest.id}")
    expect(page).to have_text("Entries: 0")
    expect(page).to have_text(I18n.t("contest.status.live"))
  end
end
