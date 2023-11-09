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
    return redirect_to(new_user_session_path, alert: "Registration is currently blocked") if Flipper.enabled?(:block_registration)

    generic_callback("facebook")
  end

  def google_oauth2
    return redirect_to(new_user_session_path, alert: "Registration is currently blocked") if Flipper.enabled?(:block_registration)

    generic_callback("google")
  end

  def github
    return redirect_to(new_user_session_path, alert: "Registration is currently blocked") if Flipper.enabled?(:block_registration)

    generic_callback("github")
  end

  def gitlab
    return redirect_to(new_user_session_path, alert: "Registration is currently blocked") if Flipper.enabled?(:block_registration)

    return unless Flipper.enabled?(:gitlab_integration)

    generic_callback("gitlab")
  end

  def microsoft_office365
    return redirect_to(new_user_session_path, alert: "Registration is currently blocked") if Flipper.enabled?(:block_registration)

    generic_callback("microsoft_office365")
  end

  def generic_callback(provider)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider.capitalize) if is_navigational_format?
    else
      session["devise.#{provider}_data"] =
        request.env["omniauth.auth"].except(:extra).except("extra")
      redirect_to new_user_registration_url
    end
  end
end
