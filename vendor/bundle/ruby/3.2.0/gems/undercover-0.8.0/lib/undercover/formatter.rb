# frozen_string_literal: true

module Undercover
  class Formatter
    def initialize(results)
      @results = results
    end

    def to_s
      return success unless @results.any?

      ([warnings_header] + formatted_warnings).join("\n")
    end

    private

    def formatted_warnings
      @results.map.with_index(1) do |res, idx|
        "🚨 #{idx}) node `#{res.node.name}` type: #{res.node.human_name},\n" +
          (' ' * pad_size) + "loc: #{res.file_path_with_lines}, " \
                             "coverage: #{res.coverage_f * 100}%\n" +
          res.pretty_print
      end
    end

    def success
      "#{Rainbow('undercover').bold.green}: ✅ No coverage " \
        'is missing in latest changes'
    end

    def warnings_header
      "#{Rainbow('undercover').bold.red}: " \
        '👮‍♂️ some methods have no test coverage! Please add specs for ' \
        'methods listed below'
    end

    def pad_size
      5 + (@results.size - 1).to_s.length
    end
  end
end
