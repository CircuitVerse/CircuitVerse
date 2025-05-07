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
  def destroy
    if current_user.valid_password?(params[:password])
      resource.destroy
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      set_flash_message! :notice, :account_deleted
      yield resource if block_given?
      respond_with_navigational(resource) { redirect_to after_sign_out_path_for(resource_name) }
    else
      redirect_to edit_user_registration_path, alert: "Incorrect password. Account deletion failed."
    end
  end

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
      return unless Flipper.enabled?(:recaptcha) && !verify_recaptcha

      self.resource = resource_class.new sign_up_params
      resource.validate # Look for any other validation errors besides reCAPTCHA
      set_minimum_password_length
      respond_with_navigational(resource) { render :new }
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
