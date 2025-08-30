# frozen_string_literal: true

module AuthComponents
  class SocialLoginComponent < ViewComponent::Base
    delegate :new_confirmation_path, to: :view_context

    def initialize(devise_mapping:, resource_name:)
      super()
      @devise_mapping = devise_mapping
      @resource_name = resource_name
    end
  end
end
