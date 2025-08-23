# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ContestCloseModalComponent, type: :component do
  it "renders heading, description and close button" do
    contest = create(:contest, status: :live)

    render_inline(described_class.new(contest: contest))

    expect(page).to have_css("#close-contest-confirmation-modal-#{contest.id}")

    expect(page).to have_text("Close a Contest")
    expect(page).to have_text("Are you sure you want to close this contest?")
    expect(page).to have_button("Confirm")
  end
end
