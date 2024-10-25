# frozen_string_literal: true

module HomepageComponents
  class FeaturedExampleCardComponent < ViewComponent::Base
    def initialize(image_path:, image_alt:, title:, link_url:)
      super
      @image_path = image_path
      @image_alt = image_alt
      @title = title
      @link_url = link_url
    end
  end
end
