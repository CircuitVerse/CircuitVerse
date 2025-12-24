# frozen_string_literal: true

# spec/components/admin/contest_update_name_modal_component_spec.rb

require "rails_helper"

RSpec.describe Admin::ContestUpdateNameModalComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:contest) { create(:contest, :live, name: "The Big Circuit Challenge") }

  # === Test 1: Verifies Modal Presence and Actions ===
  it "renders the modal structure and primary action button" do
    render_inline(described_class.new(contest: contest))

    expect(page).to have_css("#update-contest-name-modal")
    expect(page).to have_css("h4.modal-title", text: "Update Contest Name")
    expect(page).to have_button("Update Name")
    # Total 3 expectations (well within the limit)
  end

  # === Test 2: Verifies Form Integrity and Data Pre-fill ===
  it "renders the form correctly with contest data" do
    render_inline(described_class.new(contest: contest))

    expect(page).to have_css("form[action='#{admin_contest_path(':contest_id')}']")
    expect(page).to have_css("input[name='contest[name]'][type='text']")
    expect(page).to have_css("input[name='contest[name]'][value='The Big Circuit Challenge']")
    expect(page).to have_css("form#update-contest-name-form")
    # Total 4 expectations (well within the limit)
  end
end
