# frozen_string_literal: true

class NotificationComponentPreview < ViewComponent::Preview
  def default
    render(LayoutComponents::NotificationComponent.new(current_user: User.new(id: 1)))
  end
end
