# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module Threading
      class AgentThread

        def self.create(label, &blk)
          ::NewRelic::Agent.logger.debug("Creating New Relic thread: #{label}")
          wrapped_blk = Proc.new do
            begin
              blk.call
            rescue => e
              ::NewRelic::Agent.logger.error("Thread #{label} exited with error", e)
            rescue Exception => e
              ::NewRelic::Agent.logger.error("Thread #{label} exited with exception. Re-raising in case of interrupt.", e)
              raise
            ensure
              ::NewRelic::Agent.logger.debug("Exiting New Relic thread: #{label}")
            end
          end

          thread = backing_thread_class.new(&wrapped_blk)
          thread[:newrelic_label] = label
          thread
        end

        # Simplifies testing if we don't directly use ::Thread.list, so keep
        # the accessor for it here on AgentThread to use and stub.
        def self.list
          backing_thread_class.list
        end

        def self.bucket_thread(thread, profile_agent_code) #THREAD_LOCAL_ACCESS
          if thread.key?(:newrelic_label)
            profile_agent_code ? :agent : :ignore
          else
            state = Tracer.state_for(thread)
            txn   = state.current_transaction

            if    txn && !txn.recording_web_transaction?
              :background
            elsif txn &&  txn.recording_web_transaction?
              :request
            else
              :other
            end
          end
        end

        def self.scrub_backtrace(thread, profile_agent_code)
          begin
            bt = thread.backtrace
          rescue Exception => e
            ::NewRelic::Agent.logger.debug("Failed to backtrace #{thread.inspect}: #{e.class.name}: #{e.to_s}")
          end
          return nil unless bt
          bt.reject! { |t| t.include?('/newrelic_rpm-') } unless profile_agent_code
          bt
        end

        # To allow tests to swap out Thread for a synchronous alternative,
        # surface the backing class we'll use from the class level.
        @backing_thread_class = ::Thread

        def self.backing_thread_class
          @backing_thread_class
        end

        def self.backing_thread_class=(clazz)
          @backing_thread_class = clazz
        end
      end
    end
  end
end
