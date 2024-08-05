# frozen_string_literal: true

class SocialCardComponentPreview < ViewComponent::Preview
  # Default Social Card
  # @param link_url
  # @param image_path
  # @param image_alt
  # @param heading
  # @param description
  def default(
    link_url: "mailto:support@circuitverse.org",
    image_path: "SVGs/email.svg",
    image_alt: "Email Icon",
    heading: "email_us_heading",
    description: "support@circuitverse.org"
  )
    render(SocialCardComponent.new(
      link_url: link_url,
      image_path: image_path,
      image_alt: image_alt,
      heading: heading,
      description: description
    ))
  end
end
