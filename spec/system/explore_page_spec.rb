# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore page", :js, type: :system do
  before do
    enable_contests!
    flipper_enable(:circuit_explore_page)
  end

  it "renders sections and paginates Recent" do
    author = FactoryBot.create(:user)
    Array.new(25) do
      FactoryBot.create(:project, author: author, project_access_type: "Public", image_preview: "x.png")
    end

    visit "/explore"
    expect(page).to have_content(I18n.t("explore.sections.cotw.heading"))
    expect(page).to have_content(I18n.t("explore.sections.picks.heading"))

    click_button I18n.t("explore.tabs.recent")
    expect(page).to have_content(I18n.t("explore.sections.recent.heading"))

    expect(page).to have_selector(".project-card", minimum: 1)
    click_link I18n.t("pagination.next", default: "Next")
    expect(page).to have_current_path(%r{/explore\?section=recent&before_id=\d+(#recent)?})
  end

  it "shows share button on cards" do
    FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png")
    visit "/explore"
    expect(page).to have_selector(".project-card-share-btn")
  end
end
