# frozen_string_literal: true

class Circuitverse::ContributeCardComponent < ViewComponent::Base
  def initialize(image_src:, alt_text:, title_key:, items:, column_classes: "col-12 col-sm-12 col-md-6 col-lg-4")
    super
    @image_src = image_src
    @alt_text = alt_text
    @title_key = title_key
    @items = items
    @column_classes = column_classes
  end
end
