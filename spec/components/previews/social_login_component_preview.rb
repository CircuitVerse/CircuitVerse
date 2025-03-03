class SocialLoginComponentPreview < ViewComponent::Preview
  def default
    fake_mapping = OpenStruct.new(confirmable?: true)
    render(AuthComponents::SocialLoginComponent.new(devise_mapping: fake_mapping, resource_name: :user))
  end
end
