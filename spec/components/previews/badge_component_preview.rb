# frozen_string_literal: true

class BadgeComponentPreview < ViewComponent::Preview
  def default
    render(Home::BadgeComponent.new(text: "Free and Open Source"))
  end

  def without_dot
    render(Home::BadgeComponent.new(text: "Statistics", should_show_dot: false))
  end
end
