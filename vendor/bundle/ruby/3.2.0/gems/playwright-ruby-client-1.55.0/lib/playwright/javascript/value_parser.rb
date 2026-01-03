require 'base64'
require 'time'

module Playwright
  module JavaScript
    class ValueParser
      def initialize(hash)
        @hash = hash
        @refs = {}
      end

      # @return [Hash]
      def parse
        if @hash.nil?
          nil
        else
          parse_hash(@hash)
        end
      end

      # ref: https://github.com/microsoft/playwright/blob/b45905ae3f1a066a8ecb358035ce745ddd21cf3a/src/protocol/serializers.ts#L42
      # ref: https://github.com/microsoft/playwright-python/blob/25a99d53e00e35365cf5113b9525272628c0e65f/playwright/_impl/_js_handle.py#L140
      private def parse_hash(hash)
        %w(n s b).each do |key|
          return hash[key] if hash.key?(key)
        end

        if hash.key?('ref')
          return @refs[hash['ref']]
        end

        if hash.key?('v')
          return case hash['v']
                 when 'undefined'
                  nil
                 when 'null'
                  nil
                 when 'NaN'
                  Float::NAN
                 when 'Infinity'
                  Float::INFINITY
                 when '-Infinity'
                  -Float::INFINITY when '-0'
                  -0
                 end
        end

        if hash.key?('d')
          return Time.parse(hash['d'])
        end

        if hash.key?('u')
          return URI(hash['u'])
        end

        if hash.key?('bi')
          return hash['bi'].to_i
        end

        if hash.key?('e')
          return ::Playwright::Error.new(
            message: hash['e']['m'],
            name: hash['e']['n'],
            stack: hash['e']['s'].split("\n"),
          )
        end

        if hash.key?('m')
          return parse_hash(hash['m']).to_h
        end

        if hash.key?('se')
          return Set.new(parse_hash(hash['se']))
        end

        if hash.key?('r')
          # @see https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/RegExp
          # @see https://docs.ruby-lang.org/ja/latest/class/Regexp.html
          js_regex_flag = hash['r']['f']
          flags = []
          flags << Regexp::IGNORECASE if js_regex_flag.include?('i')
          flags << Regexp::MULTILINE if js_regex_flag.include?('m') || js_regex_flag.include?('s')

          return Regexp.compile(hash['r']['p'], flags.inject(:|))
        end

        if hash.key?('a')
          result = []
          if hash['id']
            @refs[hash['id']] = result
          end
          hash['a'].each { |value| result << parse_hash(value) }
          return result
        end

        if hash.key?('o')
          result = {}
          if hash['id']
            @refs[hash['id']] = result
          end
          hash['o'].each { |obj| result[obj['k']] = parse_hash(obj['v']) }
          return result
        end

        if hash.key?('h')
          return @handles[hash['h']]
        end

        if hash.key?('ta')
          encoded_bytes = hash['ta']['b']
          decoded_bytes = Base64.strict_decode64(encoded_bytes)
          array_type = hash['ta']['k']

          if array_type == 'i8'
            word_size = 1
            unpack_format = 'c*' # signed char
          elsif array_type == 'ui8' || array_type == 'ui8c'
            word_size = 1
            unpack_format = 'C*' # unsigned char
          elsif array_type == 'i16'
            word_size = 2
            unpack_format = 's<*' # signed short, little-endian
          elsif array_type == 'ui16'
            word_size = 2
            unpack_format = 'S<*' # unsigned short, little-endian
          elsif array_type == 'i32'
            word_size = 4
            unpack_format = 'l<*' # signed long, little-endian
          elsif array_type == 'ui32'
            word_size = 4
            unpack_format = 'L<*' # unsigned long, little-endian
          elsif array_type == 'f32'
            word_size = 4
            unpack_format = 'e*' # float, little-endian
          elsif array_type == 'f64'
            word_size = 8
            unpack_format = 'E*' # double, little-endian
          elsif array_type == 'bi64'
            word_size = 8
            unpack_format = 'q<*' # signed long long, little-endian
          elsif array_type == 'bui64'
            word_size = 8
            unpack_format = 'Q<*' # unsigned long long, little-endian
          else
            raise ArgumentError, "Unsupported array type: #{array_type}"
          end

          byte_len = decoded_bytes.bytesize
          if byte_len.zero?
            return []
          end

          if byte_len % word_size != 0
            raise ArgumentError, "Decoded bytes length #{byte_len} is not a multiple of word size #{word_size} for type #{array_type}"
          end

          return decoded_bytes.unpack(unpack_format)
        end

        raise ArgumentError.new("Unexpected value: #{hash}")
      end
    end
  end
end
