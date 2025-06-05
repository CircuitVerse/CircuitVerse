# app/components/donation_card_component.rb
class DonationCardComponent < ViewComponent::Base
    def initialize(image_path:, link:, alt_text:, description:)
      @image_path = image_path
      @link = link
      @alt_text = alt_text
      @description = description
    end
  end
