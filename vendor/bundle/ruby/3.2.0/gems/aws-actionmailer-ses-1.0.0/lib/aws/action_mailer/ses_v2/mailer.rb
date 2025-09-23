# frozen_string_literal: true

require 'aws-sdk-sesv2'

module Aws
  module ActionMailer
    module SESV2
      # Provides a delivery method for ActionMailer that uses Amazon Simple Email Service V2.
      #
      # Delivery settings are used to construct a new Aws::SESV2::Client instance.
      # Once you have a delivery method, you can configure your Rails environment to use it:
      #
      #     config.action_mailer.delivery_method = :ses_v2
      #     config.action_mailer.ses_v2_settings = { region: 'us-west-2' }
      #
      # @see https://guides.rubyonrails.org/action_mailer_basics.html
      class Mailer
        attr_reader :settings

        # @param [Hash] settings Passes along initialization settings to
        #   [Aws::SESV2::Client.new](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SESV2/Client.html#initialize-instance_method).
        def initialize(settings = {})
          @settings = settings
          @client = Aws::SESV2::Client.new(settings)
          @client.config.user_agent_frameworks << 'aws-actionmailer-ses'
        end

        # Delivers a Mail::Message object. Called during mail delivery.
        def deliver!(message)
          params = { content: { raw: { data: message.to_s } } }
          params[:from_email_address] = from_email_address(message)
          params[:destination] = {
            to_addresses: to_addresses(message),
            cc_addresses: message.cc,
            bcc_addresses: message.bcc
          }

          @client.send_email(params).tap do |response|
            message.header[:ses_message_id] = response.message_id
          end
        end

        private

        # smtp_envelope_from will default to the From address *without* sender names.
        # By omitting this param, SESv2 will correctly use sender names from the mail headers.
        # We should only use smtp_envelope_from when it was explicitly set (instance variable set)
        def from_email_address(message)
          message.instance_variable_get(:@smtp_envelope_from) ? message.smtp_envelope_from : nil
        end

        # smtp_envelope_to will default to the full destinations (To, Cc, Bcc)
        # SES v2 API prefers each component split out into a destination hash.
        # When smtp_envelope_to was set, use it explicitly for to_address only.
        def to_addresses(message)
          message.instance_variable_get(:@smtp_envelope_to) ? message.smtp_envelope_to : message.to
        end
      end
    end
  end
end
