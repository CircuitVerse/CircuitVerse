module Playwright
  class EventEmitterCallback
    def initialize(callback_proc)
      @proc = callback_proc
    end

    def call(*args)
      @proc.call(*args)
      true
    end
  end

  class EventEmitterOnceCallback < EventEmitterCallback
    def call(*args)
      @__result ||= super
      true
    end
  end

  module EventListenerInterface
    def on(event, callback)
      raise NotImplementedError.new('NOT IMPLEMENTED')
    end

    def off(event, callback)
      raise NotImplementedError.new('NOT IMPLEMENTED')
    end

    def once(event, callback)
      raise NotImplementedError.new('NOT IMPLEMENTED')
    end
  end

  # A subset of Events/EventEmitter in Node.js
  module EventEmitter
    # @param event [String]
    # @returns [Boolean]
    def emit(event, *args)
      handled = false
      if (callbacks = (@__event_emitter ||= {})[event.to_s])
        callbacks.dup.each do |callback|
          perform_event_emitter_callback(event, callback, args)
          handled = true
        end
      end
      handled
    end

    private def listener_count(event)
      ((@__event_emitter ||= {})[event.to_s] ||= Set.new).count
    end

    # can be overriden
    private def perform_event_emitter_callback(event, callback, args)
      callback.call(*args)
    end

    # @param event [String]
    # @param callback [Proc]
    def on(event, callback)
      raise ArgumentError.new('callback must not be nil') if callback.nil?
      cb = (@__event_emitter_callback ||= {})["#{event}/#{callback.object_id}"] ||= EventEmitterCallback.new(callback)
      ((@__event_emitter ||= {})[event.to_s] ||= Set.new) << cb
      self
    end

    # @param event [String]
    # @param callback [Proc]
    def once(event, callback)
      raise ArgumentError.new('callback must not be nil') if callback.nil?

      cb = (@__event_emitter_callback ||= {})["#{event}/once/#{callback.object_id}"] ||= EventEmitterOnceCallback.new(callback)
      ((@__event_emitter ||= {})[event.to_s] ||= Set.new) << cb
      self
    end

    # @param event [String]
    # @param callback [Proc]
    def off(event, callback)
      raise ArgumentError.new('callback must not be nil') if callback.nil?

      cb = (@__event_emitter_callback ||= {})["#{event}/#{callback.object_id}"]
      if cb
        (@__event_emitter ||= {})[event.to_s]&.delete(cb)
      end
      self
    end
  end
end
