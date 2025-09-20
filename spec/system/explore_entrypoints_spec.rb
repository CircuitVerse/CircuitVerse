# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore entrypoints", type: :system do
  before { driven_by(:rack_test) }

  it "does not show nav Explore when flag off" do
    Flipper.disable(:circuit_explore_page)
    visit "/"
    expect(page).not_to have_link("Explore", href: "/explore")
  end

  it "shows nav Explore when flag on" do
    Flipper.enable(:circuit_explore_page)
    visit "/"
    expect(page).to have_link("Explore", href: "/explore")
  end
end
