# frozen_string_literal: true

class Home::FeatureCardComponent < ViewComponent::Base
  def initialize(image_path:, alt_text:, title:, description:)
    super
    @image_path = image_path
    @alt_text = alt_text
    @title = title
    @description = description
  end

  private

    attr_reader :image_path, :alt_text, :title, :description
end
