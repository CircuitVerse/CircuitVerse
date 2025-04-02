# frozen_string_literal: true

class SocialLoginComponentPreview < ViewComponent::Preview
  def default
    fake_mapping = Struct.new(:confirmable?).new(true)
    render(AuthComponents::SocialLoginComponent.new(devise_mapping: fake_mapping, resource_name: :user))
  end
end
