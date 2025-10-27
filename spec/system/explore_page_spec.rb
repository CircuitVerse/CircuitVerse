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
    expect(page).to have_content("Circuit of the week")
    expect(page).to have_content("Editor Picks")

    click_button "Recent Circuits"
    expect(page).to have_content("Recent Circuits")

    expect(page).to have_selector(".project-card", minimum: 1)
    click_link "Next"
    expect(page).to have_current_path(%r{/explore\?section=recent&after=[^#&]+(#recent)?})
  end
end
