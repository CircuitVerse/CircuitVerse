module Playwright
  class Error < StandardError
    # ref: https://github.com/microsoft/playwright-python/blob/0b4a980fed366c4c1dee9bfcdd72662d629fdc8d/playwright/_impl/_helper.py#L155
    def self.parse(error_payload)
      if error_payload['name'] == 'TimeoutError'
        TimeoutError.new(
          message: error_payload['message'],
          stack: error_payload['stack'],
        )
      elsif error_payload['name'] == 'TargetClosedError'
        TargetClosedError.new(
          message: error_payload['message'],
          stack: error_payload['stack'],
        )
      else
        new(
          name: error_payload['name'],
          message: error_payload['message'],
          stack: error_payload['stack'],
        )
      end
    end

    # @param name [String]
    # @param message [String]
    # @param stack [Array<String>]
    def initialize(message:, name: nil, stack: nil)
      super(message)
      @name = name
      @message = message
      @stack = stack
    end

    attr_reader :name, :message, :stack

    def log=(log)
      return unless log
      format_call_log = log.join("\n  - ")
      @message = "#{@message}\nCall log:\n#{format_call_log}\n"
    end
  end

  class DriverCrashedError < StandardError
    def initialize
      super("[BUG] Playwright driver is crashed!")
    end
  end

  class TimeoutError < Error
    def initialize(message:, stack: [])
      super(name: 'TimeoutError', message: message, stack: stack)
    end
  end

  class TargetClosedError < Error
    def initialize(message: nil, stack: [])
      _message = message || 'Target page, context or browser has been closed'
      super(name: 'TargetClosedError', message: _message, stack: stack)
    end
  end

  class WebError
    def initialize(error, page)
      @error = error
      @page = PlaywrightApi.wrap(page)
    end

    attr_reader :error, :page
  end

  class AssertionError < StandardError; end
end
