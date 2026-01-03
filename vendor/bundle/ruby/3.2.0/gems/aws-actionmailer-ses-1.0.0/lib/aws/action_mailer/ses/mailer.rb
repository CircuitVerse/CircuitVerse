# frozen_string_literal: true

require 'aws-sdk-ses'

module Aws
  module ActionMailer
    module SES
      # Provides a delivery method for ActionMailer that uses Amazon Simple Email Service.
      #
      # Delivery settings are used to construct a new Aws::SES::Client instance.
      # Once you have a delivery method, you can configure your Rails environment to use it:
      #
      #     config.action_mailer.delivery_method = :ses
      #     config.action_mailer.ses_settings = { region: 'us-west-2' }
      #
      # @see https://guides.rubyonrails.org/action_mailer_basics.html
      class Mailer
        attr_reader :settings

        # @param [Hash] settings Passes along initialization options to
        #   [Aws::SES::Client.new](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SES/Client.html#initialize-instance_method).
        def initialize(settings = {})
          @settings = settings
          @client = Aws::SES::Client.new(settings)
          @client.config.user_agent_frameworks << 'aws-actionmailer-ses'
        end

        # Delivers a Mail::Message object. Called during mail delivery.
        def deliver!(message)
          params = {
            raw_message: { data: message.to_s },
            source: message.smtp_envelope_from, # defaults to From header
            destinations: message.smtp_envelope_to # defaults to destinations (To,Cc,Bcc)
          }
          @client.send_raw_email(params).tap do |response|
            message.header[:ses_message_id] = response.message_id
          end
        end
      end
    end
  end
end
