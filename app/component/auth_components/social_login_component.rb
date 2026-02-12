# frozen_string_literal: true

module AuthComponents
  class SocialLoginComponent < ViewComponent::Base
    delegate :new_confirmation_path, to: :view_context

    def initialize(devise_mapping:, resource_name:, controller_name:)
      super()
      @devise_mapping = devise_mapping
      @resource_name = resource_name
      @controller_name = controller_name
    end

    def title
      @controller_name == "registrations" ? t("users.shared.continue_with") : t("users.shared.login_with")
    end
  end
end

