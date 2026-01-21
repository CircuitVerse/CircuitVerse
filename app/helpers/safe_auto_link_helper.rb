# frozen_string_literal: true

module SafeAutoLinkHelper
  # Maximum number of characters to process with auto_link to prevent ReDoS attacks
  # Note: This refers to character count, not byte length
  MAX_AUTO_LINK_LENGTH = 10_000

  # Timeout in seconds for auto_link processing
  AUTO_LINK_TIMEOUT = 2

  # Safely converts URLs in text to clickable links with timeout and length protection
  # to prevent Regexp::TimeoutError (ReDoS attacks)
  #
  # @param text [String] the text to process
  # @param options [Hash] options to pass to auto_link
  # @return [String] the text with URLs converted to links, or sanitized original text on failure
  def safe_auto_link(text, options = {})
    return "" if text.blank?
    return sanitized_truncated_text(text) if text.length > MAX_AUTO_LINK_LENGTH

    Timeout.timeout(AUTO_LINK_TIMEOUT) { auto_link(text, options) }
  rescue Timeout::Error, Regexp::TimeoutError => e
    Rails.logger.warn("SafeAutoLinkHelper: Timeout while processing auto_link - #{e.class}")
    sanitized_truncated_text(text)
  rescue StandardError => e
    Rails.logger.error("SafeAutoLinkHelper: Unexpected error - #{e.class}\n#{Array(e.backtrace).first(5).join("\n")}")
    sanitized_truncated_text(text)
  end

  private

    def sanitized_truncated_text(text)
      h(text.truncate(MAX_AUTO_LINK_LENGTH, omission: "... [content truncated]"))
    end
end
