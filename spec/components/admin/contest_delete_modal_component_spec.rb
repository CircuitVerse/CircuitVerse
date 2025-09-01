# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ContestDeleteModalComponent, type: :component do
  include Rails.application.routes.url_helpers

  it "renders a unique modal and a Delete submit for a completed contest" do
    contest = create(:contest, status: :completed)

    render_inline(described_class.new(contest: contest))

    expect(page).to have_css("#delete-contest-confirmation-modal-#{contest.id}")

    expect(page).to have_selector("form[action='#{admin_contest_path(contest)}'][method='post']", visible: :all)
    expect(page).to have_selector("input[name='_method'][value='delete']", visible: :all)

    expect(page).to have_button("Delete")
  end
end
