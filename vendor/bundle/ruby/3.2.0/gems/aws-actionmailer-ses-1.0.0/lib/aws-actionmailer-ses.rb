# frozen_string_literal: true

require_relative 'aws/action_mailer/ses/mailer'
require_relative 'aws/action_mailer/ses_v2/mailer'
require_relative 'aws/action_mailer/railtie' if defined?(Rails::Railtie)

module Aws
  module ActionMailer
    module SES
      VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
    end

    module SESV2
      VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
    end
  end
end
