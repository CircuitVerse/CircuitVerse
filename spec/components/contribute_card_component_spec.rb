# frozen_string_literal: true

require "rails_helper"

RSpec.describe Circuitverse::ContributeCardComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:image_src) { "SVGs/student.svg" }
  let(:alt_text) { "Student Icon" }
  let(:title_key) { "circuitverse.contribute.student_card.main_heading" }
  let(:items) do
    [
      "circuitverse.contribute.student_card.item1_text",
      "circuitverse.contribute.student_card.item2_text_html",
      "circuitverse.contribute.student_card.item3_text"
    ]
  end

  it "renders the contribute card with required elements" do
    render_inline(
      described_class.new(
        image_src: image_src,
        alt_text: alt_text,
        title_key: title_key,
        items: items
      )
    )

    expect(page).to have_css(".card-spacing-d-flex")
    expect(page).to have_css(".card.contribute-card")
    expect(page).to have_css(".card-body.contribute-card-body")
  end

  it "renders the card structure elements" do
    render_inline(
      described_class.new(
        image_src: image_src,
        alt_text: alt_text,
        title_key: title_key,
        items: items
      )
    )

    expect(page).to have_css(".card-img-top.contribute-card-image")
    expect(page).to have_css("h3.card-title")
    expect(page).to have_css("ul.card-text")
  end

  it "renders the image with correct attributes" do
    render_inline(
      described_class.new(
        image_src: image_src,
        alt_text: alt_text,
        title_key: title_key,
        items: items
      )
    )

    expect(page).to have_css("img[alt='#{alt_text}']")
    expect(page).to have_css("img.card-img-top.contribute-card-image")
  end

  it "renders the correct number of list items" do
    render_inline(
      described_class.new(
        image_src: image_src,
        alt_text: alt_text,
        title_key: title_key,
        items: items
      )
    )

    expect(page).to have_css("li", count: items.length)
  end
end
