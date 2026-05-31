# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore tabs", :js, type: :system do
  before do
    Flipper.enable(:circuit_explore_page)
  end

  # rubocop:disable RSpec/MultipleExpectations
  it "switches sections without reload" do
    visit "/explore"
    expect(page).to have_button("Circuit of the week")
    expect(page).to have_button("Recent Circuits")

    expect(page).to have_css('.explore-section[data-key="cotw"]:not(.d-none)')
    expect(page).to have_css('.explore-section[data-key="recent"].d-none', visible: :all)

    click_button "Recent Circuits"
    expect(page).to have_css('.explore-section[data-key="recent"]:not(.d-none)')
    expect(page).to have_css('.explore-section[data-key="cotw"].d-none', visible: :all)
  end
  # rubocop:enable RSpec/MultipleExpectations

  it "falls back to COTW when section param is invalid and canonicalizes the URL" do
    visit "/explore?section=bogus"
    expect(page).to have_css('.explore-tab[data-key="cotw"].active')
    expect(page).to have_css('.explore-section[data-key="cotw"]:not(.d-none)')
    expect(page).to have_css('.explore-section[data-key="recent"].d-none', visible: :all)

    expect(page).to have_current_path(%r{/explore\?section=cotw})
    expect(page.evaluate_script("window.location.hash")).to eq("#cotw")
  end
end
