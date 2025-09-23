# frozen_string_literal: true
require 'stringio'
require 'rexml/document'
require 'rexml/formatters/pretty'

module Undercover
  module Checkstyle
    class Formatter
      def initialize(results)
        @results = results
      end

      def to_s
        file_annotations = warnings_to_annotations.group_by { |annotation| annotation[:path] }

        doc = REXML::Document.new
        doc << REXML::XMLDecl.new('1.0', 'UTF-8')
        checkstyle = REXML::Element.new('checkstyle', doc)
        file_annotations.each do |path, annotations|
          checkstyle << file_element(path, annotations)
        end

        output = StringIO.new
        pretty_formatter = REXML::Formatters::Pretty.new
        pretty_formatter.write(doc, output)
        output.string
      end

      private

      def format_lines(lines)
        prev = lines[0]
        slices = lines.slice_before do |e|
          (prev + 1 != e).tap { prev = e }
        end
        slices.map { |slice_first, *, slice_last| slice_last ? (slice_first..slice_last) : slice_first }
      end

      def file_element(path, annotations)
        file = REXML::Element.new('file')
        file.attributes['name'] = path
        annotations.each do |annotation|
          error = REXML::Element.new('error', file)
          error.attributes['line'] = annotation[:end_line]
          error.attributes['column'] = 0
          error.attributes['severity'] = 'warning'
          error.attributes['message'] = annotation[:message]
          error.attributes['source'] = annotation[:title]
        end
        file
      end

      # SEE: https://github.com/grodowski/undercover-ci/blob/master/lib/check_runs/complete.rb
      def warnings_to_annotations
        @results.map do |result|
          # TODO: duplicates pronto-undercover logic, move to Undercover::Result
          lines = result.coverage.map { |ln, _cov| ln if result.uncovered?(ln) }.compact
          message = "#{result.node.human_name.capitalize} `#{result.node.name}` is missing" \
                    " coverage for line#{'s' if lines.size > 1} #{format_lines(lines).join(',')}" \
                    " (node coverage: #{result.coverage_f})"
          {
            path: result.file_path,
            start_line: result.first_line,
            end_line: result.last_line,
            annotation_level: "warning",
            title: "Untested #{result.node.human_name}",
            message: message
          }
        end
      end
    end
  end
end
