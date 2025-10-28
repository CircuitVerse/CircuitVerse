# frozen_string_literal: true

require "rails_helper"

RSpec.describe Home::FeatureCardComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders feature card with image, title and description" do
    rendered = render_inline(described_class.new(
                               image_path: "homepage/export-hd.png",
                               alt_text: "Export HD",
                               title: "Export HD Images",
                               description: "Export your circuits as high definition images"
                             ))

    expect(rendered.css(".home-feature-card")).to be_present
    expect(rendered.css("img").first["src"]).to include("export-hd")
    expect(rendered.css("img").first["alt"]).to eq("Export HD")
    expect(rendered.css(".card-title").text).to eq("Export HD Images")
    expect(rendered.css(".card-text").text).to eq("Export your circuits as high definition images")
  end
end
