# frozen_string_literal: true

class PrimaryButtonComponent < ViewComponent::Base
  def initialize(label:, url:, css_classes:)
    super
    @label = label
    @url = url
    @css_classes = css_classes
  end
end
