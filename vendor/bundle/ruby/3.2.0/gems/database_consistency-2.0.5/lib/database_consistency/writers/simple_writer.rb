# frozen_string_literal: true

module DatabaseConsistency
  # The module contains formatters
  module Writers
    # The simplest formatter
    class SimpleWriter < BaseWriter
      def write
        results.select(&method(:write?))
               .map(&method(:writer))
               .group_by(&:unique_key)
               .each_value do |writers|
          puts message(writers)
        end
      end

      private

      def message(writers)
        msg = writers.first.msg
        return msg if writers.size == 1

        "#{msg}. Total grouped offenses: #{writers.size}"
      end

      def write?(report)
        report.status == :fail || config.debug?
      end

      def writer(report)
        klass =
          if report.error_slug
            begin
              "DatabaseConsistency::Writers::Simple::#{report.error_slug.to_s.classify}".constantize
            rescue NameError
              Simple::DefaultMessage
            end
          else
            Simple::DefaultMessage
          end

        klass.new(report, config: config)
      end
    end
  end
end
