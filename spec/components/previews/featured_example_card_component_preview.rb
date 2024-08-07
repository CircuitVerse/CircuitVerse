# frozen_string_literal: true

class FeaturedExampleCardComponentPreview < ViewComponent::Preview
  # Featured Example Card
  # This component is used to render a card with an image, title, and link.
  # @param image_path [String]
  # @param image_alt [String]
  # @param title [String]
  # @param link_url [String]

  def default(image_path: "homepage/rippleCarry.jpg", image_alt: "Ripple Carry", title: "Ripple Carry", link_url: "https://circuitverse.org/users/3/projects/248")
    render(HomepageComponents::FeaturedExampleCardComponent.new(
      image_path: image_path,
      image_alt: image_alt,
      title: title,
      link_url: link_url
    ))
  end
end
