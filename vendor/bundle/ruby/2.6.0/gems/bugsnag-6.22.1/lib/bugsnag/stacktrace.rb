require_relative 'code_extractor'

module Bugsnag
  module Stacktrace
    # e.g. "org/jruby/RubyKernel.java:1264:in `catch'"
    BACKTRACE_LINE_REGEX = /^((?:[a-zA-Z]:)?[^:]+):(\d+)(?::in `([^']+)')?$/

    # e.g. "org.jruby.Ruby.runScript(Ruby.java:807)"
    JAVA_BACKTRACE_REGEX = /^(.*)\((.*)(?::([0-9]+))?\)$/

    ##
    # Process a backtrace and the configuration into a parsed stacktrace.
    #
    # @param backtrace [Array, nil] If nil, 'caller' will be used instead
    # @param configuration [Configuration]
    # @return [Array]
    def self.process(backtrace, configuration)
      code_extractor = CodeExtractor.new(configuration)

      backtrace = caller if !backtrace || backtrace.empty?

      processed_backtrace = backtrace.map do |trace|
        # Parse the stacktrace line
        if trace.match(BACKTRACE_LINE_REGEX)
          file, line_str, method = [$1, $2, $3]
        elsif trace.match(JAVA_BACKTRACE_REGEX)
          method, file, line_str = [$1, $2, $3]
        end

        next if file.nil?

        # Expand relative paths
        file = File.realpath(file) rescue file

        # Generate the stacktrace line hash
        trace_hash = { lineNumber: line_str.to_i }

        # Save a copy of the file path as we're about to modify it but need the
        # raw version when extracting code (otherwise we can't open the file)
        raw_file_path = file.dup

        # Clean up the file path in the stacktrace
        if defined?(configuration.project_root) && configuration.project_root.to_s != ''
          trace_hash[:inProject] = true if file.start_with?(configuration.project_root.to_s)
          file.sub!(/#{configuration.project_root}\//, "")
          trace_hash.delete(:inProject) if file.match(configuration.vendor_path)
        end

        # Strip common gem path prefixes
        if defined?(Gem)
          file = Gem.path.inject(file) {|line, path| line.sub(/#{path}\//, "") }
        end

        trace_hash[:file] = file

        # Add a method if we have it
        trace_hash[:method] = method if method && (method =~ /^__bind/).nil?

        # If we're going to send code then record the raw file path and the
        # trace_hash, so we can extract from it later
        code_extractor.add_file(raw_file_path, trace_hash) if configuration.send_code

        trace_hash
      end.compact

      code_extractor.extract! if configuration.send_code

      processed_backtrace
    end
  end
end
