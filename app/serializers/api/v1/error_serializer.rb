# frozen_string_literal: true

class Api::V1::ErrorSerializer
  UNKNOWN_ERROR = "Something Unexpectedly Went Wrong! Please open a github issue."

  def initialize(status, errors)
    @status = status
    @errors = if errors.is_a? ActiveModel::Errors
      parse_am_errors(errors)
    else
      [errors].flatten
    end
  end

  def as_json
    {
      errors: errors
    }
  end

  private

    def parse_am_errors(errors)
      error_messages = errors.full_messages

      errors.map.with_index do |(k, v), i|
        ErrorDecorator.new(k, v, error_messages[i])
      end
    end

    def errors
      @errors.map do |error|
        {
          status: @status,
          title: normalize_title(error),
          detail: normalize_error(error)
        }
      end
    end

    def normalize_title(error)
      error.try(:title) || error.try(:to_s) || UNKNOWN_ERROR
    end

    def normalize_error(error)
      error.try(:details) || error.try(:to_s) || UNKNOWN_ERROR
    end

    class ErrorDecorator
      def initialize(key, value, message)
        @key = key
        @value = value
        @message = message
      end

      def title
        @value
      end

      def details
        @value
      end

      def to_s
        @message
      end
    end
end
