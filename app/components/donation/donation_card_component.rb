# frozen_string_literal: true

class Donation::DonationCardComponent < ViewComponent::Base
  def initialize(image_path:, link:, alt_text:, description:)
    super()
    @image_path = image_path
    @link = link
    @alt_text = alt_text
    @description = description
  end
end
