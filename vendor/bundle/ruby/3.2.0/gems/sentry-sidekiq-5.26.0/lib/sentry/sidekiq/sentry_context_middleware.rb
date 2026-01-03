# frozen_string_literal: true

require "sentry/sidekiq/context_filter"

module Sentry
  module Sidekiq
    module Helpers
      def set_span_data(span, id:, queue:, latency: nil, retry_count: nil)
        return unless span

        span.set_data(Span::DataConventions::MESSAGING_MESSAGE_ID, id)
        span.set_data(Span::DataConventions::MESSAGING_DESTINATION_NAME, queue)
        span.set_data(Span::DataConventions::MESSAGING_MESSAGE_RECEIVE_LATENCY, latency) if latency
        span.set_data(Span::DataConventions::MESSAGING_MESSAGE_RETRY_COUNT, retry_count) if retry_count
      end

      if ::Gem::Version.new(::Sidekiq::VERSION) >= ::Gem::Version.new("8.0.0")
        def calculate_latency(job)
          now_in_ms - job["enqueued_at"] if job["enqueued_at"]
        end
      else
        def calculate_latency(job)
          ((Time.now.to_f - job["enqueued_at"]) * 1000).round if job["enqueued_at"]
        end
      end

      def now_in_ms
        ::Process.clock_gettime(::Process::CLOCK_REALTIME, :millisecond)
      end
    end

    class SentryContextServerMiddleware
      include Sentry::Sidekiq::Helpers

      OP_NAME = "queue.process"
      SPAN_ORIGIN = "auto.queue.sidekiq"

      def call(worker, job, queue)
        return yield unless Sentry.initialized?

        context_filter = Sentry::Sidekiq::ContextFilter.new(job)

        Sentry.clone_hub_to_current_thread
        scope = Sentry.get_current_scope
        if (user = job["sentry_user"])
          scope.set_user(user)
        end
        scope.set_tags(queue: queue, jid: job["jid"])
        scope.set_tags(build_tags(job["tags"]))
        scope.set_contexts(sidekiq: job.merge("queue" => queue))
        scope.set_transaction_name(context_filter.transaction_name, source: :task)
        transaction = start_transaction(scope, job["trace_propagation_headers"])

        if transaction
          scope.set_span(transaction)

          latency = calculate_latency(job)

          set_span_data(
            transaction,
            id: job["jid"],
            queue: queue,
            latency: latency,
            retry_count: job["retry_count"] || 0
          )
        end

        begin
          yield
        rescue
          finish_transaction(transaction, 500)
          raise
        end

        finish_transaction(transaction, 200)
        # don't need to use ensure here
        # if the job failed, we need to keep the scope for error handler. and the scope will be cleared there
        scope.clear
      end

      def build_tags(tags)
        Array(tags).each_with_object({}) { |name, tags_hash| tags_hash[:"sidekiq.#{name}"] = true }
      end

      def start_transaction(scope, env)
        options = {
          name: scope.transaction_name,
          source: scope.transaction_source,
          op: OP_NAME,
          origin: SPAN_ORIGIN
        }

        transaction = Sentry.continue_trace(env, **options)
        Sentry.start_transaction(transaction: transaction, **options)
      end

      def finish_transaction(transaction, status)
        return unless transaction

        transaction.set_http_status(status)
        transaction.finish
      end
    end

    class SentryContextClientMiddleware
      include Sentry::Sidekiq::Helpers

      def call(worker_class, job, queue, _redis_pool)
        return yield unless Sentry.initialized?

        user = Sentry.get_current_scope.user
        job["sentry_user"] = user unless user.empty?

        if Sentry.configuration.sidekiq.propagate_traces
          job["trace_propagation_headers"] ||= Sentry.get_trace_propagation_headers
        end

        Sentry.with_child_span(op: "queue.publish", description: worker_class.to_s) do |span|
          set_span_data(span, id: job["jid"], queue: queue)

          yield
        end
      end
    end
  end
end
