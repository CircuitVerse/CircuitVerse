class FeatureCardComponent < ViewComponent::Base
    def initialize(image:, alt:, title:, text:)
      @image = image.present? ? ActionController::Base.helpers.asset_path(image) : nil
      @alt = alt
      @title = title
      @text = text
    end
  end 
  