# frozen_string_literal: true

class SocialCardComponent < ViewComponent::Base
  def initialize(link_url:, image_path:, image_alt:, heading:, description:)
    super
    @link_url = link_url
    @image_path = image_path
    @image_alt = image_alt
    @heading = heading
    @description = description
  end
end
