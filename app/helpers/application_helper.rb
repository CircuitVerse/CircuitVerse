# frozen_string_literal: true

module ApplicationHelper
  def compact_number(number)
    return number.to_s if number.nil? || number < 1000

    case number
    when 1_000...1_000_000
      format_compact_number(number, 1_000, "K")
    when 1_000_000...1_000_000_000
      format_compact_number(number, 1_000_000, "M")
    when 1_000_000_000...1_000_000_000_000
      format_compact_number(number, 1_000_000_000, "B")
    else
      format_compact_number(number, 1_000_000_000_000, "T")
    end
  end

  private

    def format_compact_number(number, divisor, suffix)
      result = number.to_f / divisor
      if result == result.to_i
        "#{result.to_i}#{suffix}"
      elsif result < 10
        "#{result.round(1)}#{suffix}"
      else
        "#{result.round}#{suffix}"
      end
    end
end
