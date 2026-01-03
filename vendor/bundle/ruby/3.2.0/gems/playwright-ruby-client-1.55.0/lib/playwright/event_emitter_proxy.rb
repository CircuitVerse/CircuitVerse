module Playwright
  class EventEmitterProxy
    include EventEmitter

    # @param src [PlaywrightApi]
    # @param dest [EventEmitter]
    def initialize(api, impl)
      @api = api
      @impl = impl
      @listeners = {}
    end

    def on(event, callback)
      if listener_count(event) == 0
        subscribe(event)
      end
      super
    end

    def once(event, callback)
      if listener_count(event) == 0
        subscribe(event)
      end
      super
    end

    def off(event, callback)
      super
      if listener_count(event) == 0
        unsubscribe(event)
      end
    end

    private def subscribe(event)
      @listeners[event] = ->(*args) {
        wrapped_args = args.map { |arg| ::Playwright::PlaywrightApi.wrap(arg) }
        emit(event, *wrapped_args)
      }
      @impl.on(event, @listeners[event])
    end

    private def unsubscribe(event)
      listener = @listeners.delete(event)
      if listener
        @impl.off(event, listener)
      end
    end
  end
end
