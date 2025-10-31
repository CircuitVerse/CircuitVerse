# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ContestUpdateNameModalComponent, type: :component do
  include Rails.application.routes.url_helpers

  it "renders the update-name form pre-filled with the current contest name" do
    
    contest = create(:contest, :live, name: "The Big Circuit Challenge")

    
    render_inline(described_class.new(contest: contest))
   
    expect(page).to have_css("#update-contest-name-modal")
    expect(page).to have_css("h4.modal-title", text: "Update Contest Name")
    expect(page).to have_button("Update Name")
    expect(page).to have_css("form[action='#{admin_contest_path(':contest_id')}']")
    expect(page).to have_css("input[name='contest[name]'][type='text']")
    expect(page).to have_css("input[name='contest[name]'][value='The Big Circuit Challenge']")
    expect(page).to have_css("form#update-contest-name-form")
  end
end