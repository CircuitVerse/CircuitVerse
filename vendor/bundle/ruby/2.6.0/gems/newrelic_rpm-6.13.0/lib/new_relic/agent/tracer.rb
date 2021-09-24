# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/transaction'
require 'new_relic/agent/transaction/segment'
require 'new_relic/agent/transaction/datastore_segment'
require 'new_relic/agent/transaction/external_request_segment'
require 'new_relic/agent/transaction/message_broker_segment'

module NewRelic
  module Agent
    #
    # This class helps you interact with the current transaction (if
    # it exists), start new transactions/segments, etc.
    #
    # @api public
    class Tracer
      class << self
        def state
          state_for(Thread.current)
        end

        alias_method :tl_get, :state

        # Returns +true+ unless called from within an
        # +NewRelic::Agent.disable_all_tracing+ block.
        #
        # @api public
        def tracing_enabled?
          state.tracing_enabled?
        end

        # Returns the transaction in progress for this thread, or
        # +nil+ if none exists.
        #
        # @api public
        def current_transaction
          state.current_transaction
        end

        # Returns the trace_id of the current_transaction, or +nil+ if
        # none exists.
        #
        # @api public
        def current_trace_id
          if txn = current_transaction
            txn.trace_id
          end
        end
        alias_method :trace_id, :current_trace_id

        # Returns the id of the current span, or +nil+ if none exists.
        #
        # @api public
        def current_span_id
          if span = current_segment
            span.guid
          end
        end
        alias_method :span_id, :current_span_id

        # Returns a boolean indicating whether the current_transaction
        # is sampled, or +nil+ if there is no current transaction.
        #
        # @api public
        def transaction_sampled?
          if txn = current_transaction
            txn.sampled?
          end
        end
        alias_method :sampled?, :transaction_sampled?

        # Runs the given block of code in a transaction.
        #
        # @param [String] name reserved for New Relic internal use
        #
        # @param [String] partial_name a meaningful name for this
        #   transaction (e.g., +blogs/index+); the Ruby agent will add a
        #   New-Relic-specific prefix
        #
        # @param [Symbol] category +:web+ for web transactions or
        #   +:background+ for background transactions
        #
        # @param [Hash] options reserved for New Relic internal use
        #
        # @api public
        def in_transaction(name: nil,
                           partial_name: nil,
                           category: nil,
                           options: {})

          finishable = start_transaction_or_segment(
            name: name,
            partial_name: partial_name,
            category: category,
            options: options
          )

          begin
            # We shouldn't raise from Tracer.start_transaction_or_segment, but
            # only wrap the yield to be absolutely sure we don't report agent
            # problems as app errors
            yield
          rescue => exception
            current_transaction.notice_error(exception)
            raise
          ensure
            finishable.finish if finishable
          end
        end

        # Starts a segment on the current transaction (if one exists)
        # or starts a new transaction otherwise.
        #
        # @param [String] name reserved for New Relic internal use
        #
        # @param [String] partial_name a meaningful name for this
        #   transaction (e.g., +blogs/index+); the Ruby agent will add a
        #   New-Relic-specific prefix
        #
        # @param [Symbol] category +:web+ for web transactions or
        #   +:task+ for background transactions
        #
        # @param [Hash] options reserved for New Relic internal use
        #
        # @return [Object, #finish] an object that responds to
        #   +finish+; you _must_ call +finish+ on it at the end of the
        #   code you're tracing
        #
        # @api public
        def start_transaction_or_segment(name: nil,
                                         partial_name: nil,
                                         category: nil,
                                         options: {})
          if name.nil? && partial_name.nil?
            raise ArgumentError, 'missing required argument: name or partial_name'
          end
          if category.nil?
            raise ArgumentError, 'missing required argument: category'
          end

          if name
            options[:transaction_name] = name
          else
            options[:transaction_name] = Transaction.name_from_partial(
              partial_name,
              category
            )
          end

          if (txn = current_transaction)
            txn.create_nested_segment(category, options)
          else
            Transaction.start_new_transaction(state, category, options)
          end

        rescue ArgumentError
          raise
        rescue => exception
          log_error('start_transaction_or_segment', exception)
        end

        # Takes name or partial_name and a category.
        # Returns a transaction instance or nil
        def start_transaction(name: nil,
                              partial_name: nil,
                              category: nil,
                              **options)
          if name.nil? && partial_name.nil?
            raise ArgumentError, 'missing required argument: name or partial_name'
          end
          if category.nil?
            raise ArgumentError, 'missing required argument: category'
          end

          return current_transaction if current_transaction

          if name
            options[:transaction_name] = name
          else
            options[:transaction_name] = Transaction.name_from_partial(
              partial_name,
              category
            )
          end

          Transaction.start_new_transaction(state,
                                            category,
                                            options)
        rescue ArgumentError
          raise
        rescue => exception
          log_error('start_transaction', exception)
        end

        def create_distributed_trace_payload
          return unless txn = current_transaction
          txn.distributed_tracer.create_distributed_trace_payload
        end

        def accept_distributed_trace_payload(payload)
          return unless txn = current_transaction
          txn.distributed_tracer.accept_distributed_trace_payload(payload)
        end

        # Returns the currently active segment in the transaction in
        # progress for this thread, or +nil+ if no segment or
        # transaction exists.
        #
        # @api public
        def current_segment
          return unless txn = current_transaction
          txn.current_segment
        end

        # Creates and starts a general-purpose segment used to time
        # arbitrary code.
        #
        # @param [String] name full name of the segment; the agent
        #   will not add a prefix. Third-party users should begin the
        #   name with +Custom/+; e.g.,
        #   +Custom/UserMailer/send_welcome_email+
        #
        # @param [optional, String, Array] unscoped_metrics additional
        #   unscoped metrics to record using this segment's timing
        #   information
        #
        # @param start_time [optional, Time] a +Time+ instance
        #   denoting the start time of the segment. Value is set by
        #   AbstractSegment#start if not given.
        #
        # @param parent [optional, Segment] Use for the rare cases
        #   (such as async) where the parent segment should be something
        #   other than the current segment
        #
        # @return [Segment] the newly created segment; you _must_ call
        #   +finish+ on it at the end of the code you're tracing
        #
        # @api public
        def start_segment(name:nil,
                          unscoped_metrics:nil,
                          start_time: nil,
                          parent: nil)

          # ruby 2.0.0 does not support required kwargs
          raise ArgumentError, 'missing required argument: name' if name.nil?

          segment = Transaction::Segment.new name, unscoped_metrics, start_time
          start_and_add_segment segment, parent

        rescue ArgumentError
          raise
        rescue => exception
          log_error('start_segment', exception)
        end

        UNKNOWN = "Unknown".freeze
        OTHER = "other".freeze

        # Creates and starts a datastore segment used to time
        # datastore operations.
        #
        # @param [String] product the datastore name for use in metric
        #   naming, e.g. "FauxDB"
        #
        # @param [String] operation the name of the operation
        #   (e.g. "select"), often named after the method that's being
        #   instrumented.
        #
        # @param [optional, String] collection the collection name for use in
        #   statement-level metrics (i.e. table or model name)
        #
        # @param [optional, String] host the host this database
        #   instance is running on
        #
        # @param [optional, String] port_path_or_id TCP port, file
        #   path, UNIX domain socket, or other connection-related info
        #
        # @param [optional, String] database_name the name of this
        #   database
        #
        # @param start_time [optional, Time] a +Time+ instance
        #   denoting the start time of the segment. Value is set by
        #   AbstractSegment#start if not given.
        #
        # @param parent [optional, Segment] Use for the rare cases
        #   (such as async) where the parent segment should be something
        #   other than the current segment
        #
        # @return [DatastoreSegment] the newly created segment; you
        #   _must_ call +finish+ on it at the end of the code you're
        #   tracing
        #
        # @api public
        def start_datastore_segment(product: nil,
                                    operation: nil,
                                    collection: nil,
                                    host: nil,
                                    port_path_or_id: nil,
                                    database_name: nil,
                                    start_time: nil,
                                    parent: nil)

          product ||= UNKNOWN
          operation ||= OTHER

          segment = Transaction::DatastoreSegment.new product, operation, collection, host, port_path_or_id, database_name
          start_and_add_segment segment, parent

        rescue ArgumentError
          raise
        rescue => exception
          log_error('start_datastore_segment', exception)
        end

        # Creates and starts an external request segment using the
        # given library, URI, and procedure. This is used to time
        # external calls made over HTTP.
        #
        # @param [String] library a string of the class name of the library used to
        #   make the external call, for example, 'Net::HTTP'.
        #
        # @param [String, URI] uri indicates the URI to which the
        #   external request is being made. The URI should begin with the protocol,
        #   for example, 'https://github.com'.
        #
        # @param [String] procedure the HTTP method being used for the external
        #   request as a string, for example, 'GET'.
        #
        # @param start_time [optional, Time] a +Time+ instance
        #   denoting the start time of the segment. Value is set by
        #   AbstractSegment#start if not given.
        #
        # @param parent [optional, Segment] Use for the rare cases
        #   (such as async) where the parent segment should be something
        #   other than the current segment
        #
        # @return [ExternalRequestSegment] the newly created segment;
        #   you _must_ call +finish+ on it at the end of the code
        #   you're tracing
        #
        # @api public
        def start_external_request_segment(library: nil,
                                           uri: nil,
                                           procedure: nil,
                                           start_time: nil,
                                           parent: nil)

          # ruby 2.0.0 does not support required kwargs
          raise ArgumentError, 'missing required argument: library' if library.nil?
          raise ArgumentError, 'missing required argument: uri' if uri.nil?
          raise ArgumentError, 'missing required argument: procedure' if procedure.nil?

          segment = Transaction::ExternalRequestSegment.new library, uri, procedure, start_time
          start_and_add_segment segment, parent

        rescue ArgumentError
          raise
        rescue => exception
          log_error('start_external_request_segment', exception)
        end

        # Will potentially capture and notice an error at the
        # segment that was executing when error occurred.
        # if passed +segment+ is something that doesn't 
        # respond to +notice_segment_error+ then this method
        # is effectively just a yield to the given &block
        def capture_segment_error segment
          return unless block_given?
          yield
        rescue => exception
          if segment && segment.is_a?(Transaction::AbstractSegment)
            segment.notice_error exception
          end
          raise
        end

        # For New Relic internal use only.
        def start_message_broker_segment(action: nil,
                                         library: nil,
                                         destination_type: nil,
                                         destination_name: nil,
                                         headers: nil,
                                         parameters: nil,
                                         start_time: nil,
                                         parent: nil)

          # ruby 2.0.0 does not support required kwargs
          raise ArgumentError, 'missing required argument: action' if action.nil?
          raise ArgumentError, 'missing required argument: library' if library.nil?
          raise ArgumentError, 'missing required argument: destination_type' if destination_type.nil?
          raise ArgumentError, 'missing required argument: destination_name' if destination_name.nil?

          segment = Transaction::MessageBrokerSegment.new(
            action: action,
            library: library,
            destination_type: destination_type,
            destination_name: destination_name,
            headers: headers,
            parameters: parameters,
            start_time: start_time
          )
          start_and_add_segment segment, parent

        rescue ArgumentError
          raise
        rescue => exception
          log_error('start_datastore_segment', exception)
        end

        # This method should only be used by Tracer for access to the
        # current thread's state or to provide read-only accessors for other threads
        #
        # If ever exposed, this requires additional synchronization
        def state_for(thread)
          state = thread[:newrelic_tracer_state]

          if state.nil?
            state = Tracer::State.new
            thread[:newrelic_tracer_state] = state
          end

          state
        end

        alias_method :tl_state_for, :state_for

        def clear_state
          Thread.current[:newrelic_tracer_state] = nil
        end

        alias_method :tl_clear, :clear_state

        private

        def start_and_add_segment segment, parent = nil
          tracer_state = state
          if (txn = tracer_state.current_transaction) &&
            tracer_state.tracing_enabled?
            txn.add_segment segment, parent
          else
            segment.record_metrics = false
          end
          segment.start
          segment
        end

        def log_error(method_name, exception)
          NewRelic::Agent.logger.error("Exception during Tracer.#{method_name}", exception)
          nil
        end
      end

      # This is THE location to store thread local information during a transaction
      # Need a new piece of data? Add a method here, NOT a new thread local variable.
      class State

        def initialize
          @untraced = []
          @current_transaction = nil
          @record_sql = nil
        end

        # This starts the timer for the transaction.
        def reset(transaction=nil)
          # We purposefully don't reset @untraced or @record_sql
          # since those are managed by NewRelic::Agent.disable_* calls explicitly
          # and (more importantly) outside the scope of a transaction

          @current_transaction = transaction
          @sql_sampler_transaction_data = nil
        end

        # Current transaction stack
        attr_reader :current_transaction

        # Execution tracing on current thread
        attr_accessor :untraced

        def push_traced(should_trace)
          @untraced << should_trace
        end

        def pop_traced
          @untraced.pop if @untraced
        end

        def is_execution_traced?
          @untraced.nil? || @untraced.last != false
        end

        alias_method :tracing_enabled?, :is_execution_traced?

        # TT's and SQL
        attr_accessor :record_sql

        def is_sql_recorded?
          @record_sql != false
        end

        # Sql Sampler Transaction Data
        attr_accessor :sql_sampler_transaction_data
      end
    end

    TransactionState = Tracer
  end
end
