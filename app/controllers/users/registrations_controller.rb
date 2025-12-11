# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]
  before_action :configure_sign_up_params, only: [:create]
  invisible_captcha only: %i[create update], honeypot: :subtitle unless Rails.env.test?
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    if Flipper.enabled?(:block_registration)
      redirect_to new_user_session_path, alert: "Registration is currently blocked"
    else
      super
    end
  end

  # POST /resource
  def create
    if Flipper.enabled?(:block_registration)
      redirect_to new_user_session_path,
                  alert: "Registration is currently blocked"
    end

    super do |user|
      if user.persisted?
        # Generate JWT token
        token = JsonWebToken.encode(user_id: user.id, username: user.name, email: user.email, remember_me: false)

        # Set JWT token as cookie
        cookies[:cvt] = {
          value: token,
          # httponly: true,
          secure: Rails.env.production?,
          same_site: :strict
        }
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name age])
  end

  private

    def check_captcha
      return unless Flipper.enabled?(:recaptcha)

      # Safely verify recaptcha with proper error handling
      recaptcha_ok = safe_verify_recaptcha

      # Only strict true is considered success
      return if recaptcha_ok == true

      # Recaptcha verification failed
      begin
        self.resource = resource_class.new(sign_up_params)
        resource.validate # Look for any other validation errors besides reCAPTCHA
        set_minimum_password_length if respond_to?(:set_minimum_password_length, true)
      rescue StandardError => e
        # If params are not available (e.g., in test environment), create an empty resource
        Rails.logger.debug("Error creating resource for captcha failure: #{e.message}")
        self.resource = resource_class.new
      end

      # Add user-friendly error message
      flash.now[:alert] = I18n.t("devise.registrations.captcha_failed",
                                   default: "Captcha verification failed. Please try again.")

      respond_with_navigational(resource) { render :new }
    end

    def safe_verify_recaptcha
      result = verify_recaptcha
      # Coerce to strict boolean: only true is success
      result == true
    rescue Recaptcha::RecaptchaError => e
      # Capture the exception to Sentry for diagnosis
      Rails.logger.error("Recaptcha verification error: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

      # Capture to Sentry if available
      if defined?(Sentry)
        Sentry.capture_exception(e, extra: {
          request_id: request.request_id,
          user_agent: request.user_agent,
          remote_ip: request.remote_ip
        })
      end

      # Treat as failed verification
      false
    end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
