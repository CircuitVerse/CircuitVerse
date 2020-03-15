# frozen_string_literal: true

require 'erb_lint'
require 'active_support'
require 'active_support/inflector'
require 'optparse'
require 'psych'
require 'yaml'
require 'rainbow'

module ERBLint
  class CLI
    DEFAULT_CONFIG_FILENAME = '.erb-lint.yml'
    DEFAULT_LINT_ALL_GLOB = "**/*.html{+*,}.erb"

    class ExitWithFailure < RuntimeError; end
    class ExitWithSuccess < RuntimeError; end

    class Stats
      attr_accessor :found, :corrected, :exceptions
      def initialize
        @found = 0
        @corrected = 0
        @exceptions = 0
      end
    end

    def initialize
      @options = {}
      @config = nil
      @files = []
      @stats = Stats.new
    end

    def run(args = ARGV)
      load_options(args)
      @files = args.dup

      load_config

      if !@files.empty? && lint_files.empty?
        success!("no files found...\n")
      elsif lint_files.empty?
        success!("no files given...\n#{option_parser}")
      end

      ensure_files_exist(lint_files)

      if enabled_linter_classes.empty?
        failure!('no linter available with current configuration')
      end

      puts "Linting #{lint_files.size} files with "\
        "#{enabled_linter_classes.size} #{'autocorrectable ' if autocorrect?}linters..."
      puts

      lint_files.each do |filename|
        begin
          run_with_corrections(filename)
        rescue => e
          @stats.exceptions += 1
          puts "Exception occured when processing: #{relative_filename(filename)}"
          puts "If this file cannot be processed by erb-lint, "\
            "you can exclude it in your configuration file."
          puts e.message
          puts Rainbow(e.backtrace.join("\n")).red
          puts
        end
      end

      if @stats.corrected > 0
        corrected_found_diff = @stats.found - @stats.corrected
        if corrected_found_diff > 0
          warn(Rainbow(
            "#{@stats.corrected} error(s) corrected and #{corrected_found_diff} error(s) remaining in ERB files"
          ).red)
        else
          puts Rainbow("#{@stats.corrected} error(s) corrected in ERB files").green
        end
      elsif @stats.found > 0
        warn(Rainbow("#{@stats.found} error(s) were found in ERB files").red)
      else
        puts Rainbow("No errors were found in ERB files").green
      end

      @stats.found == 0 && @stats.exceptions == 0
    rescue OptionParser::InvalidOption, OptionParser::InvalidArgument, ExitWithFailure => e
      warn(Rainbow(e.message).red)
      false
    rescue ExitWithSuccess => e
      puts e.message
      true
    rescue => e
      warn(Rainbow("#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}").red)
      false
    end

    private

    def autocorrect?
      @options[:autocorrect]
    end

    def run_with_corrections(filename)
      file_content = File.read(filename, encoding: Encoding::UTF_8)

      runner = ERBLint::Runner.new(file_loader, @config)

      7.times do
        processed_source = ERBLint::ProcessedSource.new(filename, file_content)
        runner.run(processed_source)
        break unless autocorrect? && runner.offenses.any?

        corrector = correct(processed_source, runner.offenses)
        break if corrector.corrections.empty?
        break if processed_source.file_content == corrector.corrected_content

        @stats.corrected += corrector.corrections.size

        File.open(filename, "wb") do |file|
          file.write(corrector.corrected_content)
        end

        file_content = corrector.corrected_content
        runner.clear_offenses
      end

      @stats.found += runner.offenses.size
      runner.offenses.each do |offense|
        puts <<~EOF
          #{offense.message}#{Rainbow(' (not autocorrected)').red if autocorrect?}
          In file: #{relative_filename(filename)}:#{offense.line_range.begin}

        EOF
      end
    end

    def correct(processed_source, offenses)
      corrector = ERBLint::Corrector.new(processed_source, offenses)
      failure!(corrector.diagnostics.join(', ')) if corrector.diagnostics.any?
      corrector
    end

    def config_filename
      @config_filename ||= @options[:config] || DEFAULT_CONFIG_FILENAME
    end

    def load_config
      if File.exist?(config_filename)
        config = RunnerConfig.new(file_loader.yaml(config_filename), file_loader)
        @config = RunnerConfig.default.merge(config)
      else
        warn(Rainbow("#{config_filename} not found: using default config").yellow)
        @config = RunnerConfig.default
      end
      @config.merge!(runner_config_override)
    rescue Psych::SyntaxError => e
      failure!("error parsing config: #{e.message}")
    end

    def file_loader
      @file_loader ||= ERBLint::FileLoader.new(Dir.pwd)
    end

    def load_options(args)
      option_parser.parse!(args)
    end

    def lint_files
      if @options[:lint_all]
        pattern = File.expand_path(DEFAULT_LINT_ALL_GLOB, Dir.pwd)
        Dir[pattern].select { |filename| !excluded?(filename) }
      else
        @files
          .map { |f| Dir.exist?(f) ? Dir[File.join(f, DEFAULT_LINT_ALL_GLOB)] : f }
          .map { |f| f.include?('*') ? Dir[f] : f }
          .flatten
          .map { |f| File.expand_path(f, Dir.pwd) }
          .select { |filename| !excluded?(filename) }
      end
    end

    def excluded?(filename)
      @config.global_exclude.any? do |path|
        File.fnmatch?(path, filename)
      end
    end

    def failure!(msg)
      raise ExitWithFailure, msg
    end

    def success!(msg)
      raise ExitWithSuccess, msg
    end

    def ensure_files_exist(files)
      files.each do |filename|
        unless File.exist?(filename)
          failure!("#{filename}: does not exist")
        end
      end
    end

    def known_linter_names
      @known_linter_names ||= ERBLint::LinterRegistry.linters
        .map(&:simple_name)
        .map(&:underscore)
    end

    def enabled_linter_names
      @enabled_linter_names ||=
        @options[:enabled_linters] ||
        known_linter_names
          .select { |name| @config.for_linter(name.camelize).enabled? }
    end

    def enabled_linter_classes
      @enabled_linter_classes ||= ERBLint::LinterRegistry.linters
        .select { |klass| linter_can_run?(klass) && enabled_linter_names.include?(klass.simple_name.underscore) }
    end

    def linter_can_run?(klass)
      !autocorrect? || klass.support_autocorrect?
    end

    def relative_filename(filename)
      filename.sub("#{File.expand_path('.', Dir.pwd)}/", '')
    end

    def runner_config_override
      RunnerConfig.new(
        linters: {}.tap do |linters|
          ERBLint::LinterRegistry.linters.map do |klass|
            linters[klass.simple_name] = { 'enabled' => enabled_linter_classes.include?(klass) }
          end
        end
      )
    end

    def option_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: erblint [options] [file1, file2, ...]"

        opts.on("--config FILENAME", "Config file [default: #{DEFAULT_CONFIG_FILENAME}]") do |config|
          if File.exist?(config)
            @options[:config] = config
          else
            failure!("#{config}: does not exist")
          end
        end

        opts.on("--lint-all", "Lint all files matching #{DEFAULT_LINT_ALL_GLOB}") do |config|
          @options[:lint_all] = config
        end

        opts.on("--enable-all-linters", "Enable all known linters") do
          @options[:enabled_linters] = known_linter_names
        end

        opts.on("--enable-linters LINTER[,LINTER,...]", Array,
          "Only use specified linter", "Known linters are: #{known_linter_names.join(', ')}") do |linters|
          linters.each do |linter|
            unless known_linter_names.include?(linter)
              failure!("#{linter}: not a valid linter name (#{known_linter_names.join(', ')})")
            end
          end
          @options[:enabled_linters] = linters
        end

        opts.on("--autocorrect", "Correct offenses that can be corrected automatically (default: false)") do |config|
          @options[:autocorrect] = config
        end

        opts.on_tail("-h", "--help", "Show this message") do
          success!(opts)
        end

        opts.on_tail("--version", "Show version") do
          success!(ERBLint::VERSION)
        end
      end
    end
  end
end
