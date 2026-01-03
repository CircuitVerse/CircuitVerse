# frozen_string_literal: true

module InvisibleCaptcha
  module ControllerExt
    module ClassMethods
      def invisible_captcha(options = {})
        if options.key?(:prepend)
          prepend_before_action(options) do
            detect_spam(options)
          end
        else
          before_action(options) do
            detect_spam(options)
          end
        end
      end
    end

    private

    def detect_spam(options = {})
      if timestamp_spam?(options)
        on_timestamp_spam(options)
        return if performed?
      end

      if honeypot_spam?(options) || spinner_spam?
        on_spam(options)
      end
    end

    def on_timestamp_spam(options = {})
      if action = options[:on_timestamp_spam]
        send(action)
      else
        flash[:error] = InvisibleCaptcha.timestamp_error_message
        redirect_back(fallback_location: root_path)
      end
    end

    def on_spam(options = {})
      if action = options[:on_spam]
        send(action)
      else
        head(200)
      end
    end

    def timestamp_spam?(options = {})
      enabled = if options.key?(:timestamp_enabled)
        options[:timestamp_enabled]
      else
        InvisibleCaptcha.timestamp_enabled
      end

      return false unless enabled

      timestamp = session.delete(:invisible_captcha_timestamp)

      # Consider as spam if timestamp not in session, cause that means the form was not fetched at all
      unless timestamp
        warn_spam("Timestamp not found in session.")
        return true
      end

      time_to_submit = Time.zone.now - DateTime.iso8601(timestamp)
      threshold = options[:timestamp_threshold] || InvisibleCaptcha.timestamp_threshold

      # Consider as spam if form submitted too quickly
      if time_to_submit < threshold
        warn_spam("Timestamp threshold not reached (took #{time_to_submit.to_i}s).")
        return true
      end

      false
    end

    def spinner_spam?
      if InvisibleCaptcha.spinner_enabled && (params[:spinner].blank? || params[:spinner] != session[:invisible_captcha_spinner])
        warn_spam("Spinner value mismatch")
        return true
      end

      false
    end

    def honeypot_spam?(options = {})
      honeypot = options[:honeypot]
      scope    = options[:scope] || controller_name.singularize

      if honeypot
        # If honeypot is defined for this controller-action, search for:
        # - honeypot: params[:subtitle]
        # - honeypot with scope: params[:topic][:subtitle]
        if params[honeypot].present? || (params[scope] && params[scope][honeypot].present?)
          warn_spam("Honeypot param '#{honeypot}' was present.")
          return true
        else
          # No honeypot spam detected, remove honeypot from params to avoid UnpermittedParameters exceptions
          params.delete(honeypot) if params.key?(honeypot)
          params[scope].try(:delete, honeypot) if params.key?(scope)
        end
      else
        InvisibleCaptcha.honeypots.each do |default_honeypot|
          if params[default_honeypot].present? || (params[scope] && params[scope][default_honeypot].present?)
            warn_spam("Honeypot param '#{scope}.#{default_honeypot}' was present.")
            return true
          end
        end
      end

      false
    end

    def warn_spam(message)
      message = "[Invisible Captcha] Potential spam detected for IP #{request.remote_ip}. #{message}"

      logger.warn(message)

      ActiveSupport::Notifications.instrument(
        'invisible_captcha.spam_detected',
        message: message,
        remote_ip: request.remote_ip,
        user_agent: request.user_agent,
        controller: params[:controller],
        action: params[:action],
        url: request.url,
        params: request.filtered_parameters
      )
    end
  end
end
