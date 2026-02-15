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
  # Store Google tokens for Classroom API access
  auth = request.env["omniauth.auth"]
  @user = User.from_omniauth(auth)

  if @user.persisted?
    # Only update tokens if they are present
    token_updates = {}
    
    # Always update access token if present
    if auth.credentials.token.present?
      token_updates[:google_access_token] = auth.credentials.token
    end
    
    # Only update refresh token if present (to avoid overwriting with nil)
    if auth.credentials.refresh_token.present?
      token_updates[:google_refresh_token] = auth.credentials.refresh_token
    end
    
    # Store token expiration time if available
    if auth.credentials.expires_at.present?
      token_updates[:google_token_expires_at] = Time.at(auth.credentials.expires_at)
    end
    
    # Update user with new tokens
    @user.update(token_updates) if token_updates.any?

    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
  elsif Flipper.enabled?(:block_registration)
    redirect_to new_user_session_path, alert: t("registration_blocked")
  else
    session["devise.google_oauth2_data"] = auth.except(:extra).except("extra")
    redirect_to new_user_registration_url
  end
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
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider.capitalize) if is_navigational_format?
    elsif Flipper.enabled?(:block_registration)
      redirect_to new_user_session_path, alert: t("registration_blocked")
    else
      session["devise.#{provider}_data"] =
        request.env["omniauth.auth"].except(:extra).except("extra")
      redirect_to new_user_registration_url
    end
  end
end
