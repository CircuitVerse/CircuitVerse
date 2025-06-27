# frozen_string_literal: true

require "rails_helper"

RSpec.describe Search::SearchBarComponent, type: :component do
  it "renders the search form with default values" do
    render_inline(described_class.new)

    expect(page).to have_css("form#search-box")
    expect(page).to have_css("form[method='get'][action='/search']")
  end

  it "renders the search form with custom search path" do
    custom_path = "/custom_search"
    render_inline(described_class.new(search_path: custom_path))

    expect(page).to have_css("form[action='#{custom_path}']")
  end

  it "renders the search input field" do
    render_inline(described_class.new)

    expect(page).to have_field("q", type: "text")
  end

  it "renders with default placeholders" do
    render_inline(described_class.new)
    expected_placeholders = {
      "Users" => "Search for users",
      "Projects" => "Search for projects"
    }.to_json
    expect(page).to have_css("[data-search-bar-placeholders-value='#{expected_placeholders}']")
  end

  it "renders with custom placeholders" do
    custom_placeholders = { "A" => "B", "C" => "D" }
    render_inline(described_class.new(options: { placeholders: custom_placeholders }))
    expect(page).to have_css("[data-search-bar-placeholders-value='#{custom_placeholders.to_json}']")
  end

  it "renders the submit button" do
    render_inline(described_class.new)

    expect(page).to have_button(type: "submit")
  end
end
