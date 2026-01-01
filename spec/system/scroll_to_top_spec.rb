# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Scroll to top button", :js, type: :system do
  it "shows scroll-to-top button after scrolling and scrolls to top when clicked" do
    visit "/"

    # Button should be hidden initially
    expect(page).not_to have_css(".scroll-to-top-btn.visible")

    # Scroll down past threshold
    page.execute_script("window.scrollTo(0, 500)")
    sleep 0.5

    # Button should be visible
    expect(page).to have_css(".scroll-to-top-btn.visible")

    # Click button
    find(".scroll-to-top-btn").click
    sleep 0.5

    # Should be at top of page
    scroll_position = page.evaluate_script("window.scrollY")
    expect(scroll_position).to be < 50
  end
end
