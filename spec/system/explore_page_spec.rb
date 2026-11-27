# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore page", :js, type: :system do
  it "renders sections and paginates Recent" do
    author = FactoryBot.create(:user)
    Array.new(25) do
      project = FactoryBot.create(:project, author: author, project_access_type: "Public")
      project.circuit_preview.attach(
        io: Rails.root.join("spec/fixtures/files/default.png").open,
        filename: "default.png",
        content_type: "image/png"
      )
      project
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
