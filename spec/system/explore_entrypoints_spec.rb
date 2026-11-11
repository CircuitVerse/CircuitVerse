# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore entrypoints", type: :system do
  before { driven_by(:rack_test) }

  it "shows nav Explore" do
    visit "/"
    expect(page).to have_link("Explore", href: "/explore")
  end
end
