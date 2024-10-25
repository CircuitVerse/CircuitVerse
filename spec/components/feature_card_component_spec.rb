# frozen_string_literal: true

require "rails_helper"

RSpec.describe HomepageComponents::FeatureCardComponent, type: :component do
  it "renders the feature card with correct content" do
    render_inline(described_class.new(
      image_path: "homepage/export-hd.png",
      image_alt: "Export HD",
      title_key: "circuitverse.index.features.item1_heading",
      text_key: "circuitverse.index.features.item1_text"
    ))

    expect(page).to have_css(".card.home-feature-card")
    expect(page).to have_css("img.card-img-top[alt='Export HD']")
    expect(page).to have_css(".card-title", text: I18n.t("circuitverse.index.features.item1_heading"))
    expect(page).to have_css(".card-text", text: I18n.t("circuitverse.index.features.item1_text"))
  end
end
