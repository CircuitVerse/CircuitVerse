require_relative './visitor_info'
require_relative './regex'

module Playwright
  module JavaScript
    class ValueSerializer
      def initialize(ruby_value)
        @value = ruby_value
        @visited = VisitorInfo.new
      end

      # @return [Hash]
      def serialize
        @handles = []
        { value: serialize_value(@value), handles: @handles }
      end

      # ref: https://github.com/microsoft/playwright/blob/b45905ae3f1a066a8ecb358035ce745ddd21cf3a/src/protocol/serializers.ts#L84
      # ref: https://github.com/microsoft/playwright-python/blob/25a99d53e00e35365cf5113b9525272628c0e65f/playwright/_impl/_js_handle.py#L99
      private def serialize_value(value)
        case value
        when ChannelOwners::JSHandle
          index = @handles.count
          @handles << value.channel
          { h: index }
        when nil
          { v: 'null' }
        when Float::NAN
          { v: 'NaN'}
        when Float::INFINITY
          { v: 'Infinity' }
        when -Float::INFINITY
          { v: '-Infinity' }
        when ::Playwright::Error
          {
            e: {
              n: value.name,
              m: value.message,
              s: value.stack.join("\n")
            }
          }
        when StandardError
          {
            e: {
              n: value.class.name,
              m: value.message,
              s: (value.backtrace || []).join("\n")
            }
          }
        when true, false
          { b: value }
        when Numeric
          if !value.is_a?(Integer) || (-9007199254740992..9007199254740991).include?(value)
            { n: value }
          else
            { bi: value.to_s }
          end
        when String
          { s: value }
        when Time
          require 'time'
          { d: value.utc.iso8601 }
        when URI
          { u: value.to_s }
        when Regexp
          regex_value = Regex.new(value)
          { r: { p: regex_value.source, f: regex_value.flag } }
        when -> (value) { @visited.ref(value) }
          { ref: @visited.ref(value) }
        when Array
          id = @visited.log(value)
          result = []
          value.each { |v| result << serialize_value(v) }
          { a: result, id: id }
        when Set
          { se: serialize_value(value.to_a) }
        when Hash
          if value.any? { |k, v| !k.is_a?(String) && !k.is_a?(Symbol) } # Map
            { m: serialize_value(value.to_a) }
          else
            id = @visited.log(value)
            result = []
            value.each { |key, v| result << { k: key, v: serialize_value(v) } }
            { o: result, id: id }
          end
        else
          raise ArgumentError.new("Unexpected value: #{value}")
        end
      end
    end
  end
end
