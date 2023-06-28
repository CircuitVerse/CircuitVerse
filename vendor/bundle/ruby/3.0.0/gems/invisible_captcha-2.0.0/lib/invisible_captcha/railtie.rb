# frozen_string_literal: true

module InvisibleCaptcha
  class Railtie < Rails::Railtie
    initializer 'invisible_captcha.rails_integration' do
      ActiveSupport.on_load(:action_controller) do
        include InvisibleCaptcha::ControllerExt
        extend InvisibleCaptcha::ControllerExt::ClassMethods
      end

      ActiveSupport.on_load(:action_view) do
        include InvisibleCaptcha::ViewHelpers
        ActionView::Helpers::FormBuilder.send :include, InvisibleCaptcha::FormHelpers
      end
    end
  end
end
