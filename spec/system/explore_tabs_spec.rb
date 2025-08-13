# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Explore tabs", type: :system do
  before do
    driven_by(:selenium, using: :headless_chrome)
    Flipper.enable(:circuit_explore_page)
  end

  it "switches sections without reload" do
    visit "/explore"
    expect(page).to have_button(I18n.t("explore.tabs.cotw"))
    expect(page).to have_button(I18n.t("explore.tabs.recent"))

    expect(page).to have_content(I18n.t("explore.sections.cotw.heading"))
    expect(page).not_to have_content(I18n.t("explore.sections.recent.heading"))

    click_button I18n.t("explore.tabs.recent")
    expect(page).to have_content(I18n.t("explore.sections.recent.heading"))
    expect(page).not_to have_content(I18n.t("explore.sections.cotw.heading"))
  end
end
