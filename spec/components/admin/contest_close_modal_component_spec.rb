# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ContestCloseModalComponent, type: :component do
  include Rails.application.routes.url_helpers

  it "renders heading, description and close button" do
    contest = create(:contest, :live)

    render_inline(described_class.new(contest: contest))

    expect(page).to have_css("#close-contest-confirmation-modal")
    expect(page).to have_css("h4.modal-title", text: "Close a Contest")
    expect(page).to have_button("Confirm")

    expect(page).to have_css("form[action='#{admin_contest_path(contest)}']")
  end
end
