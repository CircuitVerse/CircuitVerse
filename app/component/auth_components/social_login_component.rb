# frozen_string_literal: true

module AuthComponents
  class SocialLoginComponent < ViewComponent::Base
    delegate :new_confirmation_path, to: :view_context

    def initialize(devise_mapping:, resource_name:)
      super
      @devise_mapping = devise_mapping
      @resource_name = resource_name
    end

    def provider_link(provider)
      case provider
      when :google
        user_google_oauth2_omniauth_authorize_path
      when :facebook
        user_facebook_omniauth_authorize_path
      when :github
        user_github_omniauth_authorize_path
      when :gitlab
        user_gitlab_omniauth_authorize_path
      else
        "#"
      end
    end
  end
end