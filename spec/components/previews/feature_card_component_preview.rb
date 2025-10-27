# frozen_string_literal: true

class FeatureCardComponentPreview < ViewComponent::Preview
  def default
    render(Home::FeatureCardComponent.new(
             image_path: "homepage/export-hd.png",
             alt_text: "Export HD",
             title: "Export HD Images",
             description: "Export your circuits as high definition images"
           ))
  end
end
