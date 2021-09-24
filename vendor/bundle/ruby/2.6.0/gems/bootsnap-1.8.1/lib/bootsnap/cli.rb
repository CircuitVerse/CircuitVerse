# frozen_string_literal: true

require 'bootsnap'
require 'bootsnap/cli/worker_pool'
require 'optparse'
require 'fileutils'
require 'etc'

module Bootsnap
  class CLI
    unless Regexp.method_defined?(:match?)
      module RegexpMatchBackport
        refine Regexp do
          def match?(string)
            !!match(string)
          end
        end
      end
      using RegexpMatchBackport
    end

    attr_reader :cache_dir, :argv

    attr_accessor :compile_gemfile, :exclude, :verbose, :iseq, :yaml, :jobs

    def initialize(argv)
      @argv = argv
      self.cache_dir = ENV.fetch('BOOTSNAP_CACHE_DIR', 'tmp/cache')
      self.compile_gemfile = false
      self.exclude = nil
      self.verbose = false
      self.jobs = Etc.nprocessors
      self.iseq = true
      self.yaml = true
    end

    def precompile_command(*sources)
      require 'bootsnap/compile_cache/iseq'
      require 'bootsnap/compile_cache/yaml'

      fix_default_encoding do
        Bootsnap::CompileCache::ISeq.cache_dir = self.cache_dir
        Bootsnap::CompileCache::YAML.init!
        Bootsnap::CompileCache::YAML.cache_dir = self.cache_dir

        @work_pool = WorkerPool.create(size: jobs, jobs: {
          ruby: method(:precompile_ruby),
          yaml: method(:precompile_yaml),
        })
        @work_pool.spawn

        main_sources = sources.map { |d| File.expand_path(d) }
        precompile_ruby_files(main_sources)
        precompile_yaml_files(main_sources)

        if compile_gemfile
          # Some gems embed their tests, they're very unlikely to be loaded, so not worth precompiling.
          gem_exclude = Regexp.union([exclude, '/spec/', '/test/'].compact)
          precompile_ruby_files($LOAD_PATH.map { |d| File.expand_path(d) }, exclude: gem_exclude)

          # Gems that include YAML files usually don't put them in `lib/`.
          # So we look at the gem root.
          gem_pattern = %r{^#{Regexp.escape(Bundler.bundle_path.to_s)}/?(?:bundler/)?gems\/[^/]+}
          gem_paths = $LOAD_PATH.map { |p| p[gem_pattern] }.compact.uniq
          precompile_yaml_files(gem_paths, exclude: gem_exclude)
        end

        if exitstatus = @work_pool.shutdown
          exit(exitstatus)
        end
      end
      0
    end

    dir_sort = begin
      Dir[__FILE__, sort: false]
      true
    rescue ArgumentError, TypeError
      false
    end

    if dir_sort
      def list_files(path, pattern)
        if File.directory?(path)
          Dir[File.join(path,  pattern), sort: false]
        elsif File.exist?(path)
          [path]
        else
          []
        end
      end
    else
      def list_files(path, pattern)
        if File.directory?(path)
          Dir[File.join(path,  pattern)]
        elsif File.exist?(path)
          [path]
        else
          []
        end
      end
    end

    def run
      parser.parse!(argv)
      command = argv.shift
      method = "#{command}_command"
      if respond_to?(method)
        public_send(method, *argv)
      else
        invalid_usage!("Unknown command: #{command}")
      end
    end

    private

    def precompile_yaml_files(load_paths, exclude: self.exclude)
      return unless yaml

      load_paths.each do |path|
        if !exclude || !exclude.match?(path)
          list_files(path, '**/*.{yml,yaml}').each do |yaml_file|
            # We ignore hidden files to not match the various .ci.yml files
            if !File.basename(yaml_file).start_with?('.') && (!exclude || !exclude.match?(yaml_file))
              @work_pool.push(:yaml, yaml_file)
            end
          end
        end
      end
    end

    def precompile_yaml(*yaml_files)
      Array(yaml_files).each do |yaml_file|
        if CompileCache::YAML.precompile(yaml_file, cache_dir: cache_dir)
          STDERR.puts(yaml_file) if verbose
        end
      end
    end

    def precompile_ruby_files(load_paths, exclude: self.exclude)
      return unless iseq

      load_paths.each do |path|
        if !exclude || !exclude.match?(path)
          list_files(path, '**/*.rb').each do |ruby_file|
            if !exclude || !exclude.match?(ruby_file)
              @work_pool.push(:ruby, ruby_file)
            end
          end
        end
      end
    end

    def precompile_ruby(*ruby_files)
      Array(ruby_files).each do |ruby_file|
        if CompileCache::ISeq.precompile(ruby_file, cache_dir: cache_dir)
          STDERR.puts(ruby_file) if verbose
        end
      end
    end

    def fix_default_encoding
      if Encoding.default_external == Encoding::US_ASCII
        Encoding.default_external = Encoding::UTF_8
        begin
          yield
        ensure
          Encoding.default_external = Encoding::US_ASCII
        end
      else
        yield
      end
    end

    def invalid_usage!(message)
      STDERR.puts message
      STDERR.puts
      STDERR.puts parser
      1
    end

    def cache_dir=(dir)
      @cache_dir = File.expand_path(File.join(dir, 'bootsnap/compile-cache'))
    end

    def exclude_pattern(pattern)
      (@exclude_patterns ||= []) << Regexp.new(pattern)
      self.exclude = Regexp.union(@exclude_patterns)
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: bootsnap COMMAND [ARGS]"
        opts.separator ""
        opts.separator "GLOBAL OPTIONS"
        opts.separator ""

        help = <<~EOS
          Path to the bootsnap cache directory. Defaults to tmp/cache
        EOS
        opts.on('--cache-dir DIR', help.strip) do |dir|
          self.cache_dir = dir
        end

        help = <<~EOS
          Print precompiled paths.
        EOS
        opts.on('--verbose', '-v', help.strip) do
          self.verbose = true
        end

        help = <<~EOS
          Number of workers to use. Default to number of processors, set to 0 to disable multi-processing.
        EOS
        opts.on('--jobs JOBS', '-j', help.strip) do |jobs|
          self.jobs = Integer(jobs)
        end

        opts.separator ""
        opts.separator "COMMANDS"
        opts.separator ""
        opts.separator "    precompile [DIRECTORIES...]: Precompile all .rb files in the passed directories"

        help = <<~EOS
          Precompile the gems in Gemfile
        EOS
        opts.on('--gemfile', help) { self.compile_gemfile = true }

        help = <<~EOS
          Path pattern to not precompile. e.g. --exclude 'aws-sdk|google-api'
        EOS
        opts.on('--exclude PATTERN', help) { |pattern| exclude_pattern(pattern) }

        help = <<~EOS
          Disable ISeq (.rb) precompilation.
        EOS
        opts.on('--no-iseq', help) { self.iseq = false }

        help = <<~EOS
          Disable YAML precompilation.
        EOS
        opts.on('--no-yaml', help) { self.yaml = false }
      end
    end
  end
end
