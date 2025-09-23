# frozen_string_literal: true

require 'optparse'
require 'pathname'
require 'shellwords'

module Undercover
  class Options # rubocop:disable Metrics/ClassLength
    DIFF_TRIGGER_MODE = [
      # Default, analyse all code blocks with changed lines. Untested lines and branches will trigger warnings if they
      # strictly belong to the diff.
      DIFF_TRIGGER_LINE = :diff_trigger_line,
      #
      # Doesn't exist yet
      # Analyse all code blocks with changed lines. Untested lines and branches always trigger warnings for code block.
      # DIFF_TRIGGER_BLOCK = :diff_trigger_block,
      # Analyse all code blocks in each changed file.
      # DIFF_TRIGGER_FILE = :diff_trigger_file,
      # Analyse all code blocks in all files, ignores current diff (use --include-files and --exclude-files for control)
      # ALL = :all,
    ].freeze

    FILE_SCOPE = [
      # Extended scope helps identify Ruby files that are not required in the test suite.
      # Warning: currently doesn't respect :nocov: syntax in files not traced by SimpleCov.
      # (use --include-files and --exclude-files for control)
      FILE_SCOPE_EXTENDED = :scope_extended,
      #
      # Doesn't exist yet
      # Analyse file that appear in coverage reports. Historically, the default undercover mode.
      # FILE_SCOPE_COVERAGE = :scope_coverage,
    ].freeze

    DEFAULT_FILE_INCLUDE_GLOBS = %w[*.rb *.rake *.ru Rakefile].freeze
    DEFAULT_FILE_EXCLUDE_GLOBS = %w[test/* spec/* db/* config/* *_test.rb *_spec.rb].freeze

    attr_accessor :lcov,
                  :simplecov_resultset,
                  :path,
                  :git_dir,
                  :compare,
                  :syntax_version,
                  :run_mode,
                  :file_scope,
                  :glob_allow_filters,
                  :glob_reject_filters,
                  :max_warnings_limit

    def initialize
      @run_mode = DIFF_TRIGGER_LINE
      @file_scope = FILE_SCOPE_EXTENDED
      # set defaults
      self.path = '.'
      self.git_dir = '.git'
      self.glob_allow_filters = DEFAULT_FILE_INCLUDE_GLOBS
      self.glob_reject_filters = DEFAULT_FILE_EXCLUDE_GLOBS
      self.max_warnings_limit = nil
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def parse(args)
      args = build_opts(args)

      OptionParser.new do |opts|
        opts.banner = 'Usage: undercover [options]'

        opts.on_tail('-h', '--help', 'Prints this help') do
          puts(opts)
          exit
        end

        opts.on_tail('--version', 'Show version') do
          # :nocov:
          puts VERSION
          exit
          # :nocov:
        end

        lcov_path_option(opts)
        resultset_path_option(opts)
        project_path_option(opts)
        git_dir_option(opts)
        compare_option(opts)
        ruby_syntax_option(opts)
        max_warnings_limit_option(opts)
        file_filters(opts)
      end.parse(args)

      guess_resultset_path unless simplecov_resultset
      guess_lcov_path unless lcov
      self
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def build_opts(args)
      project_options.concat(args)
    end

    def project_options
      args_from_options_file(project_options_file)
    end

    def args_from_options_file(path)
      return [] unless File.exist?(path)

      File.read(path).split("\n").flat_map { parse_line(_1) }
    end

    def project_options_file
      './.undercover'
    end

    def parse_line(line)
      line = line.strip
      return [] if line.empty? || line.start_with?('#')

      Shellwords.split(line)
    end

    def split_comma_separated_with_braces(input)
      return [] if input.empty?

      input.split(/,(?![^{]*})/).map(&:strip) # split on commas that are not inside braces
    end

    def lcov_path_option(parser)
      parser.on('-l', '--lcov path', 'LCOV report file path') do |path|
        self.lcov = path
      end
    end

    def resultset_path_option(parser)
      desc = 'SimpleCov::Formatter::Undercover output file path (alternative to LCOV that will become default)'
      parser.on('-s', '--simplecov path', desc) do |path|
        self.simplecov_resultset = path
      end
    end

    def project_path_option(parser)
      parser.on('-p', '--path path', 'Project directory') do |path|
        self.path = path
      end
    end

    def git_dir_option(parser)
      desc = 'Override `.git` with a custom directory'
      parser.on('-g', '--git-dir dir', desc) do |dir|
        self.git_dir = dir
      end
    end

    def compare_option(parser)
      desc = 'Generate coverage warnings for all changes after `ref`'
      parser.on('-c', '--compare ref', desc) do |ref|
        self.compare = ref
      end
    end

    def ruby_syntax_option(parser)
      versions = Imagen::AVAILABLE_RUBY_VERSIONS.sort.join(', ')
      desc = "Ruby syntax version, one of: #{versions}"
      parser.on('-r', '--ruby-syntax ver', desc) do |version|
        self.syntax_version = version.strip
      end
    end

    def max_warnings_limit_option(parser)
      desc = 'Maximum number of warnings to generate before stopping analysis'
      parser.on('-w', '--max-warnings limit', Integer, desc) do |limit|
        self.max_warnings_limit = limit
      end
    end

    def guess_resultset_path
      cwd = Pathname.new(File.expand_path(path))
      try_path = File.join(cwd, 'coverage', 'coverage.json')
      self.simplecov_resultset = try_path if File.exist?(try_path)
    end

    def guess_lcov_path
      cwd = Pathname.new(File.expand_path(path))
      try_path = File.join(cwd, 'coverage', 'lcov', "#{cwd.split.last}.lcov")
      self.lcov = try_path if File.exist?(try_path)
    end

    def file_filters(parser)
      desc = 'Include files matching specified glob patterns (comma separated). ' \
             "Defaults to '#{DEFAULT_FILE_INCLUDE_GLOBS.join(',')}'"
      parser.on('-f', '--include-files globs', desc) do |comma_separated_globs|
        self.glob_allow_filters = split_comma_separated_with_braces(comma_separated_globs)
      end

      desc = 'Skip files matching specified glob patterns (comma separated). Empty by default.'
      parser.on('-x', '--exclude-files globs', desc) do |comma_separated_globs|
        self.glob_reject_filters = split_comma_separated_with_braces(comma_separated_globs)
      end
    end
  end
end
