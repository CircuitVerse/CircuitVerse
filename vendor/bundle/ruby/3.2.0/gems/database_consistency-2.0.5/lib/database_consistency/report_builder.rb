# frozen_string_literal: true

module DatabaseConsistency
  class ReportBuilder # :nodoc:
    def self.define(klass, *attrs)
      Class.new(klass) do
        attr_reader(*attrs)

        class_eval(<<~DEF, __FILE__, __LINE__ + 1)
          def initialize(#{attrs.map { |attr| "#{attr}:" }.join(', ')}#{"," if attrs.any?} **opts)
            super(**opts) if opts.any?
            #{attrs.map { |attr| "@#{attr} = #{attr}" }.join("\n")}
          end

          def to_h
            h = defined?(super) ? super : {}
            #{attrs.map { |attr| "h[#{attr}] = #{attr}" }.join("\n")}
            h
          end
        DEF
      end
    end
  end
end
