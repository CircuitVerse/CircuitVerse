# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ContestUpdateDeadlineModalComponent, type: :component do
  it "renders the edit-deadline form pre-filled with current deadline" do
    contest = create(:contest, :live)

    render_inline(described_class.new(contest: contest))

    expect(page).to have_css("#update-contest-modal")
    expect(page).to have_css("h4.modal-title", text: "Update Contest Deadline")

    formatted_deadline = contest.deadline.in_time_zone.strftime("%Y-%m-%dT%H:%M")
    expect(page).to have_css("input#contest_deadline[value='#{formatted_deadline}']")
    expect(page).to have_button("Update Deadline")
  end
end
