# frozen_string_literal: true

class UserCardComponentPreview < ViewComponent::Preview
  def default
    profile = ProfileDecorator.new(User.first)
    render(User::UserCardComponent.new(profile: profile))
  end
end
