# frozen_string_literal: true

# Monkey patch for aws-actionmailer-ses v1.0.0 to fix ArgumentError
# The gem passes single string emails to the AWS SDK, which strictly requires arrays.
# This patch ensures to_addresses, cc_addresses, and bcc_addresses always return arrays.
# Remove this patch once a fixed version of aws-actionmailer-ses is released and installed.

require 'aws/action_mailer/ses_v2/mailer'

module Aws
  module ActionMailer
    module SESV2
      class Mailer
        private

        # Original method returns message.to or message.smtp_envelope_to directly.
        # ActionMailer can return a String or Array. AWS SDK requires Array.
        def to_addresses(message)
          Array(message.instance_variable_get(:@smtp_envelope_to) || message.to)
        end

        def cc_addresses(message)
          Array(message.cc)
        end

        def bcc_addresses(message)
          Array(message.bcc)
        end
      end
    end
  end
end
