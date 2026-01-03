module Tins
  class Duration
    include Comparable

    # Returns the number of seconds represented by the given duration string
    # according to the provided template format.
    #
    # @param [String] string The duration string to parse.
    # @param [String] template for the duration format, see {#format}.
    #
    # @return [Integer, Float] The number of (fractional) seconds of the duration.
    #
    # @example
    #   Tins::Duration.parse('6+05:04:03', template: '%S%d+%h:%m:%s') # => 536643
    #   Tins::Duration.parse('6+05:04:03.21', template: '%S%d+%h:%m:%s.%f') # => 536643.21
    def self.parse(string, template: '%S%d+%h:%m:%s.%f')
      s, t = string.to_s.dup, template.dup
      d, sd = 0, 1
      loop do
        t.sub!(/\A(%[Sdhmsf%]|.)/) { |directive|
          case directive
          when '%S' then s.sub!(/\A-?/)   { sd *= -1 if _1 == ?-; '' }
          when '%d' then s.sub!(/\A\d+/)  { d += 86_400 * _1.to_i; '' }
          when '%h' then s.sub!(/\A\d+/)  { d += 3_600 * _1.to_i; '' }
          when '%m' then s.sub!(/\A\d+/)  { d += 60 * _1.to_i; '' }
          when '%s' then s.sub!(/\A\d+/)  { d += _1.to_i; '' }
          when '%f' then s.sub!(/\A\d+/)  { d += Float(?. + _1); '' }
          when '%%' then
            if s[0] == ?%
              s[0] = ''
            else
              raise "expected %s, got #{s.inspect}"
            end
          else
            if directive == s[0]
              s[0] = ''
            else
              raise ArgumentError, "expected #{t.inspect}, got #{s.inspect}"
            end
          end
          ''
        } or break
      end
      sd * d
    end

    def initialize(seconds)
      @negative = seconds < 0
      seconds = seconds.abs
      @original_seconds = seconds
      @days, @hours, @minutes, @seconds, @fractional_seconds =
        [ 86_400, 3600, 60, 1, 0 ].inject([ [], seconds ]) {|(r, s), d|
          if d > 0
            dd, rest = s.divmod(d)
            r << dd
            [ r, rest ]
          else
            r << s
          end
        }
    end

    def to_f
      @original_seconds.to_f
    end

    def <=>(other)
      to_f <=> other.to_f
    end

    def negative?
      @negative
    end

    def days?
      @days > 0
    end

    def hours?
      @hours > 0
    end

    def minutes?
      @minutes > 0
    end

    def seconds?
      @seconds > 0
    end

    def fractional_seconds?
      @fractional_seconds > 0
    end

    def format(template = '%S%d+%h:%m:%s.%f', precision: nil)
      result = template.gsub(/%[DdhmSs]/) { |directive|
        case directive
        when '%S' then ?- if negative?
        when '%d' then @days
        when '%h' then '%02u' % @hours
        when '%m' then '%02u' % @minutes
        when '%s' then '%02u' % @seconds
        when '%D' then format_smart
        end
      }
      if result.include?('%f')
        if precision
          fractional_seconds = "%.#{precision}f" % @fractional_seconds
        else
          fractional_seconds = '%f' % @fractional_seconds
        end
        result.gsub!('%f', fractional_seconds[2..-1])
      end
      result
    end

    def to_s
      format_smart
    end

    private

    def format_smart
      template  = '%h:%m:%s'
      precision = nil
      if days?
        template.prepend '%d+'
      end
      if fractional_seconds?
        template << '.%f'
        precision = 3
      end
      template.prepend '%S'
      format template, precision: precision
    end
  end
end
