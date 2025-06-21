# frozen_string_literal: true

class PrimaryButtonComponent < ViewComponent::Base
    def initialize(text:, link:, aria_label:)
      @text = text
      @link = link
      @aria_label = aria_label
    end
  end
  
