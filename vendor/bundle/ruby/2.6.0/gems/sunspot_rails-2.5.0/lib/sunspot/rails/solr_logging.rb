module Sunspot
  module Rails
    module SolrLogging

      COMMIT = %r{<commit/>}

      def execute_with_rails_logging(request_context)
        body = (request_context[:data]||"").dup
        action = request_context[:path].capitalize
        if body =~ COMMIT
          action = "Commit"
          body = ""
        end

        # Make request and log.
        response = nil
        begin
          ms = Benchmark.ms do
            response = execute_without_rails_logging(request_context)
          end
          log_name = 'Solr %s (%.1fms)' % [action, ms]
          ::Rails.logger.debug(format_log_entry(log_name, body))
        rescue Exception => e
          log_name = 'Solr %s (Error)' % [action]
          ::Rails.logger.error(format_log_entry(log_name, body))
          raise e
        end

        response
      end

      private

      def format_log_entry(message, dump = nil)
        @colorize_logging ||= ::Rails.application.config.colorize_logging
          
        if @colorize_logging
          message_color, dump_color = "4;32;1", "0;1"
          log_entry = "  \e[#{message_color}m#{message}\e[0m   "
          log_entry << "\e[#{dump_color}m%#{String === dump ? 's' : 'p'}\e[0m" % dump if dump
          log_entry
        else
          "%s  %s" % [message, dump]
        end
      end
    end
  end
end

RSolr::Client.class_eval do
  include Sunspot::Rails::SolrLogging
  alias_method :execute_without_rails_logging, :execute
  alias_method :execute, :execute_with_rails_logging
end
