# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  prepend_before_action :check_captcha, only: [:create]
  after_action :allow_iframe, only: %i[new]

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private

    def check_captcha
      if Flipper.enabled?(:recaptcha) && !verify_recaptcha
        self.resource = resource_class.new sign_in_params
        respond_with_navigational(resource) { render :new }
      end
    end
    
    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end
end
