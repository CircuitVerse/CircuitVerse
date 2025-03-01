class FeatureCardComponent < ViewComponent::Base
    def initialize(image:, alt:, title:, text:)
      @image = image
      @alt = alt
      @title = title
      @text = text
    end
  end