# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Explore page", type: :system do
  before do
    enable_contests!
    flipper_enable(:circuit_explore_page)
  end

  it "renders sections and paginates Recent" do
    author = FactoryBot.create(:user)
    projects = 12.times.map do
      FactoryBot.create(:project, author: author, project_access_type: "Public", image_preview: "x.png")
    end

    visit "/explore"
    expect(page).to have_content(I18n.t("explore.cotw.heading"))
    expect(page).to have_content(I18n.t("explore.editor_picks.heading"))
    expect(page).to have_content(I18n.t("explore.recent.heading"))

    expect(page).to have_selector(".project-card", minimum: 1)
    click_link "Next →"
    expect(page).to have_current_path(/explore\?page=2#recent/)
  end

  it "shows share button on cards" do
    FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png")
    visit "/explore"
    expect(page).to have_selector(".project-card-share-btn")
  end
end
