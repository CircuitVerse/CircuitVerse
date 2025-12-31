# frozen_string_literal: true

class Utf8Sanitizer
  SANITIZE_ENV_KEYS = %w[
    QUERY_STRING
    REQUEST_URI
    PATH_INFO
    REQUEST_PATH
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    SANITIZE_ENV_KEYS.each do |key|
      sanitize_key(env, key)
    end
    @app.call(env)
  end

  private

  def sanitize_key(env, key)
    return unless env[key]

    string = env[key].to_s
    return if string.frozen? && string.encoding == Encoding::UTF_8 && string.valid_encoding?

    string = string.dup if string.frozen?

    if string.encoding == Encoding::UTF_8 && string.valid_encoding?
      # Already valid UTF-8
      env[key] = string
      return
    end

    # valid_encoding? check is important because if it's tagged UTF-8 but invalid, we want to scrub.
    # If it's another encoding (like UTF-16LE), we want to transcode.

    begin
      # Try to transcode to UTF-8
      string = string.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '')
    rescue Encoding::ConverterNotFoundError, Encoding::UndefinedConversionError
      # If transcoding fails (e.g. from binary to UTF-8 but implies known encoding), force it.
      # Or if it was Binary/ASCII-8BIT, encode just assumes it's treating bytes as chars.
      string.force_encoding(Encoding::UTF_8)
    end

    unless string.valid_encoding?
      # If still not valid (e.g. forced binary to utf8 but had invalid sequences)
      string = string.scrub('')
    end

    env[key] = string
  end
end
