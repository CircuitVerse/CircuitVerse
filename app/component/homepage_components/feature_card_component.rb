module HomepageComponents
  class FeatureCardComponent < ViewComponent::Base
    def initialize(image_path:, image_alt:, title_key:, text_key:)
      super
      @image_path = image_path
      @image_alt = image_alt
      @title_key = title_key
      @text_key = text_key
    end
  end
end
