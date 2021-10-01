# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  class Control
    # Contains methods that relate to adding and executing files that
    # contain instrumentation for the Ruby Agent
    module Instrumentation

      # Adds a list of files in Dir.glob format
      # (e.g. '/app/foo/**/*_instrumentation.rb')
      # This requires the files within a rescue block, so that any
      # errors within instrumentation files do not affect the overall
      # agent or application in which it runs.
      def load_instrumentation_files pattern
        Dir.glob(pattern) do |file|
          begin
            require file.to_s
          rescue => e
            ::NewRelic::Agent.logger.warn "Error loading instrumentation file '#{file}':", e
          end
        end
      end

      def install_shim
        # implemented only in subclasses
      end

      # Add instrumentation.  Don't call this directly.  Use NewRelic::Agent#add_instrumentation.
      # This will load the file synchronously if we've already loaded the default
      # instrumentation, otherwise instrumentation files specified
      # here will be deferred until all instrumentation is run
      #
      # This happens after the agent has loaded and all dependencies
      # are ready to be instrumented
      def add_instrumentation pattern
        if @instrumented
          load_instrumentation_files pattern
        else
          @instrumentation_files << pattern
        end
      end

      # Signals the agent that it's time to actually load the
      # instrumentation files. May be overridden by subclasses
      def install_instrumentation
        _install_instrumentation
      end

      private

      def _install_instrumentation
        return if @instrumented

        @instrumented = true

        # Instrumentation for the key code points inside rails for monitoring by NewRelic.
        # note this file is loaded only if the newrelic agent is enabled (through config/newrelic.yml)
        instrumentation_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'agent','instrumentation'))
        @instrumentation_files <<
        File.join(instrumentation_path, '*.rb') <<
        File.join(instrumentation_path, app.to_s, '*.rb')
        @instrumentation_files.each { | pattern |  load_instrumentation_files pattern }
        DependencyDetection.detect!
        ::NewRelic::Agent.logger.info "Finished instrumentation"
      end
    end
    include Instrumentation
  end
end
