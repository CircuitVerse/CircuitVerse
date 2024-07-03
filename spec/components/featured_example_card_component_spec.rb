# frozen_string_literal: true

require "rails_helper"

RSpec.describe HomepageComponents::FeaturedExampleCardComponent, type: :component do
  it "renders the feature example card with correct content" do
    render_inline(described_class.new(
      image_path: "homepage/sap.jpg",
      image_alt: "SAP-1",
      title: "Sample Circuit",
      link_url: "https://circuitverse.org/users/3/projects/67"
    ))

    expect(page).to have_css(".card.circuit-card")
    expect(page).to have_css("img.card-img-top[alt='SAP-1']")
    expect(page).to have_css(".circuit-card-name p", text: "Sample Circuit")
    expect(page).to have_css(".circuit-card-name .tooltiptext", text: "Sample Circuit")
    expect(page).to have_link(I18n.t("view"), href: "https://circuitverse.org/users/3/projects/67")
  end
end