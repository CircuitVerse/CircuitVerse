# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ContestUpdateDeadlineModalComponent, type: :component do
  it "renders the edit-deadline form pre-filled with current deadline" do
    contest = create(:contest, status: :live, deadline: 2.days.from_now)

    render_inline(described_class.new(contest: contest))

    expect(page).to have_css("#update-contest-modal-#{contest.id}")

    expect(page).to have_text("Update Contest Deadline")
    expect(page).to have_text("Please ensure that the Contest Deadline is set in the future.")

    expected_value = contest.deadline.in_time_zone.strftime("%Y-%m-%dT%H:%M")
    expect(page).to have_field("contest[deadline]", with: expected_value)
    expect(page).to have_button("Update Deadline")
  end
end
