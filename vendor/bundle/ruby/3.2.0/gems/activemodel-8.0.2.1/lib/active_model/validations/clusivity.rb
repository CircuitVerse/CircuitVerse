# frozen_string_literal: true

require "active_model/validations/resolve_value"
require "active_support/core_ext/range"

module ActiveModel
  module Validations
    module Clusivity # :nodoc:
      include ResolveValue

      ERROR_MESSAGE = "An object with the method #include? or a proc, lambda or symbol is required, " \
                      "and must be supplied as the :in (or :within) option of the configuration hash"

      def check_validity!
        unless delimiter.respond_to?(:include?) || delimiter.respond_to?(:call) || delimiter.respond_to?(:to_sym)
          raise ArgumentError, ERROR_MESSAGE
        end
      end

    private
      def include?(record, value)
        members = resolve_value(record, delimiter)

        if value.is_a?(Array)
          value.all? { |v| members.public_send(inclusion_method(members), v) }
        else
          members.public_send(inclusion_method(members), value)
        end
      end

      def delimiter
        @delimiter ||= options[:in] || options[:within]
      end

      # After Ruby 2.2, <tt>Range#include?</tt> on non-number-or-time-ish ranges checks all
      # possible values in the range for equality, which is slower but more accurate.
      # <tt>Range#cover?</tt> uses the previous logic of comparing a value with the range
      # endpoints, which is fast but is only accurate on Numeric, Time, Date,
      # or DateTime ranges.
      def inclusion_method(enumerable)
        if enumerable.is_a? Range
          case enumerable.begin || enumerable.end
          when Numeric, Time, DateTime, Date
            :cover?
          else
            :include?
          end
        else
          :include?
        end
      end
    end
  end
end
