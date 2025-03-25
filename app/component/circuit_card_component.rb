# frozen_string_literal: true

class CircuitCardComponent < ViewComponent::Base
    def initialize(image:, alt:, text:, link:, height: nil, width: nil)
      @image = image
      @alt = alt
      @text = text
      @link = link
      @height = height
      @width = width
    end
  end
  
  

  
