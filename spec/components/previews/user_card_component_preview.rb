# frozen_string_literal: true

class UserCardComponentPreview < ViewComponent::Preview
  def default
    user = User.first
    profile = ProfileDecorator.new(user)
    render(UserComponents::UserCardComponent.new(profile: profile))
  end
end
