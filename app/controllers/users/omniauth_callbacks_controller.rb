# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

  def facebook
    generic_callback("facebook")
  end

  def google_oauth2
    generic_callback("google")
  end

  def github
    generic_callback("github")
  end

  def gitlab
    return unless Flipper.enabled?(:gitlab_integration)

    generic_callback("gitlab")
  end

  def microsoft_office365
    generic_callback("microsoft_office365")
  end

  def generic_callback(provider)
    auth = request.env["omniauth.auth"]

    if registration_blocked_for?(auth)
      redirect_to new_user_session_path, alert: t("registration_blocked")
      return
    end

    @user = User.from_omniauth(auth)
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider.capitalize) if is_navigational_format?
    else
      session["devise.#{provider}_data"] = auth.except(:extra).except("extra")
      redirect_to new_user_registration_url
    end
  end

  private

    # Existing users may still log in via OAuth; only new accounts are blocked.
    def registration_blocked_for?(auth)
      return false unless Flipper.enabled?(:block_registration)

      email = auth.info["email"].to_s.downcase.strip
      email.blank? || !User.exists?(email: email)
    end
end
