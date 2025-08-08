# frozen_string_literal: true

class Home::BadgeComponent < ViewComponent::Base
  def initialize(text:, should_show_dot: true)
    super
    @text = text
    @should_show_dot = should_show_dot
  end

  private

    attr_reader :text, :should_show_dot
end
