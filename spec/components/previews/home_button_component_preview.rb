# frozen_string_literal: true

class HomeButtonComponentPreview < ViewComponent::Preview
  # Home Page Button
  # This component is used to render a button on the home page.
  # @param path [String] 
  # @param text_key [String]

  def default(path: "/", text_key: "circuitverse.index.for_teachers")
    render(HomepageComponents::HomeButtonComponent.new(path: path, text_key: text_key))
  end
end
