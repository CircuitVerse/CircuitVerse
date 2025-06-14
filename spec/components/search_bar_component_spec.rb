# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchComponents::SearchBarComponent, type: :component do
  it "renders the search form" do
    render_inline(described_class.new)

    expect(page).to have_css("form#search-box")
    expect(page).to have_css("form[method='get'][action='/search']")
  end

  it "renders the select dropdown with correct options" do
    render_inline(described_class.new)

    expect(page).to have_select("resource", options: %w[Users Projects])
  end

  it "renders the search input field" do
    render_inline(described_class.new)

    expect(page).to have_field("q", type: "text")
    expect(page).to have_field("q", placeholder: "Search for projects or users")
  end

  it "renders the submit button" do
    render_inline(described_class.new)

    expect(page).to have_button("Search")
  end
end
