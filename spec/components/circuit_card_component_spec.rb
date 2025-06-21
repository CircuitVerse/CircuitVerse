# frozen_string_literal: true

require "rails_helper"

RSpec.describe CircuitCardComponent, type: :component do
  let(:image) { "homepage/export-hd.png" }

  it "renders the circuit card correctly" do
    image_path = ActionController::Base.helpers.asset_path(image)

    render_inline(CircuitCardComponent.new(
      image: image_path,
      alt: "Test Alt",
      text: "Test Circuit",
      link: "https://example.com",
      height: "180",
      width: "288"
    ))

    expect(page).to have_css("img[src*='export-hd'][alt='Test Alt']")
    expect(page).to have_text("Test Circuit")
    expect(page).to have_link(href: "https://example.com")
  end
end


