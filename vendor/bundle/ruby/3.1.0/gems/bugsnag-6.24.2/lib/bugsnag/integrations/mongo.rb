require 'mongo'
require 'bugsnag/breadcrumbs/breadcrumbs'

module Bugsnag
  ##
  # Subscribes to, and creates breadcrumbs from, mongo_ruby_driver events
  #
  # @api private
  class MongoBreadcrumbSubscriber
    MONGO_MESSAGE_PREFIX = "Mongo query "
    MONGO_EVENT_PREFIX = "mongo."
    MONGO_COMMAND_KEY = :bugsnag_mongo_commands
    MAX_FILTER_DEPTH = 5

    ##
    # Listens to the 'started' event, storing the command for later usage
    #
    # @param event [Mongo::Event::Base] the mongo_ruby_driver generated event
    def started(event)
      leave_command(event)
    end

    ##
    # Listens to the 'succeeded' event, leaving a breadcrumb
    #
    # @param event [Mongo::Event::Base] the mongo_ruby_driver generated event
    def succeeded(event)
      leave_mongo_breadcrumb("succeeded", event)
    end

    ##
    # Listens to the 'failed' event, leaving a breadcrumb
    #
    # @param event [Mongo::Event::Base] the mongo_ruby_driver generated event
    def failed(event)
      leave_mongo_breadcrumb("failed", event)
    end

    private

    ##
    # Generates breadcrumb data from an event
    #
    # @param event_name [String] the type of event
    # @param event [Mongo::Event::Base] the mongo_ruby_driver generated event
    def leave_mongo_breadcrumb(event_name, event)
      message = MONGO_MESSAGE_PREFIX + event_name
      meta_data = {
        :event_name => MONGO_EVENT_PREFIX + event_name,
        :command_name => event.command_name,
        :database_name => event.database_name,
        :operation_id => event.operation_id,
        :request_id => event.request_id,
        :duration => event.duration
      }
      if (command = pop_command(event.request_id))
        collection_key = event.command_name == "getMore" ? "collection" : event.command_name
        meta_data[:collection] = command[collection_key]
        unless command["filter"].nil?
          filter = sanitize_filter_hash(command["filter"])
          meta_data[:filter] = JSON.dump(filter)
        end
      end
      meta_data[:message] = event.message if defined?(event.message)

      Bugsnag.leave_breadcrumb(message, meta_data, Bugsnag::Breadcrumbs::PROCESS_BREADCRUMB_TYPE, :auto)
    end

    ##
    # Removes values from filter hashes, replacing them with '?'
    #
    # @param filter_hash [Hash] the filter hash for the mongo transaction
    # @param depth [Integer] the current filter depth
    #
    # @return [Hash] the filtered hash
    def sanitize_filter_hash(filter_hash, depth = 0)
      filter_hash.each_with_object({}) do |(key, value), output|
        output[key] = sanitize_filter_value(value, depth)
      end
    end

    ##
    # Transforms a value element into a useful, redacted, version
    #
    # @param value [Object] the filter value
    # @param depth [Integer] the current filter depth
    #
    # @return [Array, Hash, String] the sanitized value
    def sanitize_filter_value(value, depth)
      depth += 1
      if depth >= MAX_FILTER_DEPTH
        '[MAX_FILTER_DEPTH_REACHED]'
      elsif value.is_a?(Array)
        value.map { |array_value| sanitize_filter_value(array_value, depth) }
      elsif value.is_a?(Hash)
        sanitize_filter_hash(value, depth)
      else
        '?'
      end
    end

    ##
    # Stores the mongo command in the request data by the request_id
    #
    # @param event [Mongo::Event::Base] the mongo_ruby_driver generated event
    def leave_command(event)
      event_commands[event.request_id] = event.command
    end

    ##
    # Removes and retrieves a stored command from the request data
    #
    # @param request_id [String] the id of the mongo_ruby_driver event
    #
    # @return [Hash, nil] the requested command, or nil if not found
    def pop_command(request_id)
      event_commands.delete(request_id)
    end

    ##
    # Provides access to a thread-based mongo event command hash
    #
    # @return [Hash] the hash of mongo event commands
    def event_commands
      Bugsnag.configuration.request_data[MONGO_COMMAND_KEY] ||= {}
    end
  end
end

if defined?(Mongo::Monitoring)
  ##
  # Add the subscriber to the global Mongo monitoring object
  Mongo::Monitoring::Global.subscribe(Mongo::Monitoring::COMMAND, Bugsnag::MongoBreadcrumbSubscriber.new)
end
