module Lookbook
  class Error < StandardError
    attr_reader :scope, :original, :status, :detail, :source

    def initialize(message = nil,
      scope: nil, original: nil, status: nil, detail: nil,
      file_path: nil, source: nil, line_number: nil, **kwargs)
      @scope = scope
      @original = original
      @message = message
      @status = status
      @detail = detail
      @file_path = file_path
      @source = source
      @line_number = line_number
      super(message)
    end

    def message
      @message || original&.message
    end

    def backtrace
      original&.backtrace || super
    end

    def type
      (original.presence || self).class.to_s
    end

    def file_path
      return @file_path.to_s if @file_path.present?

      parsed_backtrace[0][0] if parsed_backtrace.any?
    end

    def relative_file_path
      file_path&.delete_prefix("#{Rails.root}/")
    end

    def line_number
      return @line_number.to_i if @line_number.present?

      if parsed_backtrace.any?
        number = parsed_backtrace[0][1]
        number.to_i if number.present?
      end
    end

    def backtrace_lines
      root = Rails.root.to_s
      backtrace.map { |line| line.gsub(root, "") }
    end

    protected

    def parsed_backtrace
      backtrace.map do |line|
        line =~ /^(.+?):(\d+)(|:in `(.+)')$/
        [$1, $2, $4]
      end
    end
  end
end
