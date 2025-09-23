# frozen_string_literal: true

module Aws
  module ActionMailer
    # @api private
    class Railtie < Rails::Railtie
      ActiveSupport.on_load(:action_mailer) do
        add_delivery_method :ses, SES::Mailer
        add_delivery_method :ses_v2, SESV2::Mailer
      end
    end
  end
end
