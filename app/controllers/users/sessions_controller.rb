# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RecaptchaVerification

  prepend_before_action :check_captcha, only: [:create]

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super do |user|
      # Check if 'Remember me' is selected
      remember_me = params.dig(:user, :remember_me) == "1"

      # Generate JWT token
      token = JsonWebToken.encode(
        user_id: user.id, username: user.name, email: user.email, remember_me: remember_me
      )

      cookie_options = {
        value: token,
        # httponly: true,
        secure: Rails.env.production?,
        same_site: :strict
      }

      # Set cookie expiration
      cookie_options[:expires] = 2.weeks.from_now if remember_me

      # Set JWT token as cookie
      cookies[:cvt] = cookie_options
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super do
      # Remove the JWT token cookie
      cookies.delete(:cvt)
    end
  end
  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private

    def check_captcha
      return unless Flipper.enabled?(:recaptcha)

      # Safely verify recaptcha with proper error handling
      recaptcha_ok = safe_verify_recaptcha

      # Only strict true is considered success
      return if recaptcha_ok == true

      # Recaptcha verification failed
      flash[:alert] = I18n.t("devise.sessions.captcha_failed",
                              default: "Captcha verification failed. Please try again.")

      redirect_to new_user_session_path
    end
end
