# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class Base # :nodoc:
        COLORS = {
          blue: "\e[34m",
          yellow: "\e[33m",
          green: "\e[32m",
          red: "\e[31m"
        }.freeze

        COLOR_BY_STATUS = {
          ok: :green,
          warning: :yellow,
          fail: :red
        }.freeze

        def self.with(text)
          Class.new(self) do
            define_method :template do
              text
            end
          end
        end

        attr_reader :report, :config

        def initialize(report, config:)
          @report = report
          @config = config
        end

        def msg
          [report.checker_name, status_text, key_text, message_text].compact.join(' ').strip
        end

        def unique_key
          { class: self.class }.merge(unique_attributes)
        end

        private

        def unique_attributes
          raise StandardError, 'Missing the implementation'
        end

        def message_text
          attributes.reduce(template) do |str, (k, v)|
            str.gsub("%<#{k}>s", v.to_s)
          end
        end

        def attributes
          {}
        end

        def key_text
          [
            colorize(report.table_or_model_name, :blue),
            colorize(report.column_or_attribute_name, :yellow)
          ].compact.join(' ')
        end

        def colorize(text, color)
          return text unless text && config.colored? && color

          "#{COLORS[color]}#{text}\e[0m"
        end

        def status_text
          color = COLOR_BY_STATUS[report.status]

          colorize(report.status, color)
        end
      end
    end
  end
end
