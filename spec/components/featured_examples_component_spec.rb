# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeaturedExamplesComponent, type: :component do
  it "renders featured examples section" do
    render_inline(described_class.new)

    expect(page).to have_css(".home-circuit-card-row")
    expect(page).to have_text(I18n.t("circuitverse.index.featured_examples.main_heading"))
    expect(page).to have_text(I18n.t("circuitverse.index.featured_examples.main_description"))
  end
end

