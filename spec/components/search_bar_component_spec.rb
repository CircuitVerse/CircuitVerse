# frozen_string_literal: true

require "rails_helper"

RSpec.describe Search::SearchBarComponent, type: :component do
  it "renders the the search bar form" do
    render_inline(described_class.new)

    expect(page).to have_css("form#search-box")
    expect(page).to have_css("form[method='get'][action='/search']")
  end

  it "renders the search input field" do
    render_inline(described_class.new)

    expect(page).to have_field("q", type: "text")
  end

  it "renders the submit button" do
    render_inline(described_class.new)

    expect(page).to have_button(type: "submit")
  end
end
