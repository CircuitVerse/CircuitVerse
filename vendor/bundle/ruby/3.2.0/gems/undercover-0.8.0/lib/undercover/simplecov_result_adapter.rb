# frozen_string_literal: true

require 'undercover/root_to_relative_paths'

module Undercover
  class SimplecovResultAdapter
    include RootToRelativePaths

    attr_reader :simplecov_result

    # @param file[File] JSON file supplied by SimpleCov::Formatter::Undercover
    # @return SimplecovResultAdapter
    def self.parse(file, opts = nil)
      # :nocov:
      result_h = JSON.parse(file.read)
      raise ArgumentError, 'empty SimpleCov' if result_h.empty?

      new(result_h, opts)
      # :nocov:
    end

    # @param simplecov_result[SimpleCov::Result]
    def initialize(simplecov_result, opts)
      @simplecov_result = simplecov_result
      @code_dir = opts&.path
    end

    # @param filepath[String]
    # @return Array tuples (lines) and quadruples (branches) compatible with LcovParser
    def coverage(filepath) # rubocop:disable Metrics/MethodLength
      source_file = find_file(filepath)

      return [] unless source_file

      lines = source_file['lines'].map.with_index do |line_coverage, idx|
        [idx + 1, line_coverage] if line_coverage
      end.compact
      return lines unless source_file['branches']

      branch_idx = 0
      branches = source_file['branches'].map do |branch|
        branch_idx += 1
        [branch['start_line'], 0, branch_idx, branch['coverage']]
      end
      lines + branches
    end

    def skipped?(filepath, line_no)
      source_file = find_file(filepath)
      return false unless source_file

      source_file['lines'][line_no - 1] == 'ignored'
    end

    # unused for now
    def total_coverage; end
    def total_branch_coverage; end

    def ignored_files
      @ignored_files ||= simplecov_result.dig('meta', 'ignored_files') || []
    end

    private

    def find_file(filepath)
      simplecov_result['coverage'][fix_relative_filepath(filepath)]
    end
  end
end
