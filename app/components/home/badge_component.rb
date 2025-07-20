# frozen_string_literal: true

class Home::BadgeComponent < ViewComponent::Base
  def initialize(text:, show_dot: true)
    super
    @text = text
    @show_dot = show_dot
  end

  private

    attr_reader :text, :show_dot
end
