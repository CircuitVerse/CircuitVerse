# frozen_string_literal: true

require 'invisible_captcha/version'
require 'invisible_captcha/controller_ext'
require 'invisible_captcha/view_helpers'
require 'invisible_captcha/form_helpers'
require 'invisible_captcha/railtie'

module InvisibleCaptcha
  class << self
    attr_writer :sentence_for_humans,
                :timestamp_error_message

    attr_accessor :honeypots,
                  :timestamp_threshold,
                  :timestamp_enabled,
                  :visual_honeypots,
                  :injectable_styles,
                  :spinner_enabled,
                  :secret

    def init!
      # Default sentence for real users if text field was visible
      self.sentence_for_humans = -> { I18n.t('invisible_captcha.sentence_for_humans', default: 'If you are a human, ignore this field') }

      # Timestamp check enabled by default
      self.timestamp_enabled = true

      # Fastest time (in seconds) to expect a human to submit the form
      self.timestamp_threshold = 4

      # Default error message for validator when form submitted too quickly
      self.timestamp_error_message = -> { I18n.t('invisible_captcha.timestamp_error_message', default: 'Sorry, that was too quick! Please resubmit.') }

      # Make honeypots visibles
      self.visual_honeypots = false

      # If enabled, you should call anywhere in your layout the following helper, to inject the honeypot styles:
      # <%= invisible_captcha_styles %>
      self.injectable_styles = false

      # Spinner check enabled by default
      self.spinner_enabled = true

      # A secret key to encode some internal values
      self.secret = ENV['INVISIBLE_CAPTCHA_SECRET'] || SecureRandom.hex(64)
    end

    def sentence_for_humans
      call_lambda_or_return(@sentence_for_humans)
    end

    def timestamp_error_message
      call_lambda_or_return(@timestamp_error_message)
    end

    def setup
      yield(self) if block_given?
    end

    def honeypots
      @honeypots ||= (1..5).map { generate_random_honeypot }
    end

    def generate_random_honeypot
      "abcdefghijkl-mnopqrstuvwxyz".chars.sample(rand(10..20)).join
    end

    def get_honeypot
      honeypots.sample
    end

    def css_strategy
      [
        "display:none;",
        "position:absolute!important;top:-9999px;left:-9999px;",
        "position:absolute!important;height:1px;width:1px;overflow:hidden;"
      ].sample
    end

    def encode(value)
      Digest::MD5.hexdigest("#{self.secret}-#{value}")
    end

    private

    def call_lambda_or_return(obj)
      obj.respond_to?(:call) ? obj.call : obj
    end
  end
end

InvisibleCaptcha.init!
