# frozen_string_literal: true

class FeatureCardComponentPreview < ViewComponent::Preview
  def default
    render(HomepageComponents::FeatureCardComponent.new(
      image_path: "homepage/export-hd.png",
      image_alt: "Export HD",
      title_key: "circuitverse.index.features.item1_heading",
      text_key: "circuitverse.index.features.item1_text"
    ))
  end
end
