# frozen_string_literal: true

module RecaptchaVerification
  extend ActiveSupport::Concern

  private

  def safe_verify_recaptcha
    result = verify_recaptcha
    # Coerce to strict boolean: only true is success
    result == true
  rescue Recaptcha::RecaptchaError => e
    # Capture the exception to Sentry for diagnosis
    Rails.logger.error("Recaptcha verification error: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))

    # Capture to Sentry if available
    if defined?(Sentry)
      Sentry.capture_exception(e, extra: {
        request_id: request.request_id,
        user_agent: request.user_agent,
        remote_ip: request.remote_ip
      })
    end

    # Treat as failed verification
    false
  end
end
