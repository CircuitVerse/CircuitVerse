require 'fileutils'
require 'pathname'
require_relative 'simplecov/lcov/version'
require_relative 'simple_cov_lcov/configuration'

fail 'simplecov-lcov requires simplecov' unless defined?(SimpleCov)

module SimpleCov
  module Formatter
    # Custom Formatter to generate lcov style coverage for simplecov
    class LcovFormatter
      # generate lcov style coverage.
      # ==== Args
      # _result_ :: [SimpleCov::Result] abcoverage result instance.
      def format(result)
        create_output_directory!

        if report_with_single_file?
          write_lcov_to_single_file!(result.files)
        else
          result.files.each { |file| write_lcov!(file) }
        end

        puts "Lcov style coverage report generated for #{result.command_name} to #{lcov_results_path}"
      end

      class << self
        def config
          @config ||= SimpleCovLcov::Configuration.new
          yield @config if block_given?
          @config
        end

        def report_with_single_file=(value)
          deprecation_message = \
            "#{caller(1..1).first} " \
            "`#{LcovFormatter}.report_with_single_file=` is deprecated. " \
            "Use `#{LcovFormatter}.config.report_with_single_file=` instead"

          warn deprecation_message
          config.report_with_single_file = value
        end
      end

      private

      def output_directory
        self.class.config.output_directory
      end

      def lcov_results_path
        report_with_single_file? ? single_report_path : output_directory
      end

      def report_with_single_file?
        self.class.config.report_with_single_file?
      end

      def single_report_path
        self.class.config.single_report_path
      end

      def create_output_directory!
        return if Dir.exist?(output_directory)
        FileUtils.mkdir_p(output_directory)
      end

      def write_lcov!(file)
        File.open(File.join(output_directory, output_filename(file.filename)), 'w') do |f|
          f.write format_file(file)
        end
      end

      def write_lcov_to_single_file!(files)
        File.open(single_report_path, 'w') do |f|
          files.each { |file| f.write format_file(file) }
        end
      end

      def output_filename(filename)
        filename.gsub("#{SimpleCov.root}/", '').gsub('/', '-')
          .tap { |name| name << '.lcov' }
      end

      def format_file(file)
        filename = file.filename.gsub("#{SimpleCov.root}/", './')
        pieces = []
        pieces << "SF:#{filename}"
        lines = format_lines(file)
        pieces << lines if lines.length > 0
        pieces << "LF:#{file.lines.count(&:coverage)}"
        pieces << "LH:#{file.lines.count(&:covered?)}"

        if SimpleCov.respond_to?(:branch_coverage?) && SimpleCov.branch_coverage?
          branch_data = format_branches(file)
          pieces << branch_data if branch_data.length > 0
          pieces << "BRF:#{file.total_branches.length}"
          pieces << "BRH:#{file.covered_branches.length}"
        end
        pieces << "end_of_record"
        pieces << ""
        pieces.join("\n")
      end

      def format_branches(file)
        branch_idx = 0
        filtered_branches(file)
          .map do |branch|
            branch_idx += 1
            format_branch(branch, branch_idx)
          end
          .join("\n")
      end

      def format_lines(file)
        filtered_lines(file)
          .map { |line| format_line(line) }
          .join("\n")
      end

      def filtered_lines(file)
        file.lines.reject(&:never?).reject(&:skipped?)
      end

      def filtered_branches(file)
        file.branches.reject(&:skipped?)
      end

      def format_branch(branch, branch_idx)
        taken = branch.coverage == 0 ? '-' : branch.coverage
        "BRDA:#{branch.report_line},0,#{branch_idx},#{taken}"
      end

      def format_line(line)
        "DA:#{line.number},#{line.coverage}"
      end
    end
  end
end
