module Playwright
  #
  # The `WebSocket` class represents WebSocket connections within a page. It provides the ability to inspect and manipulate the data being transmitted and received.
  #
  # If you want to intercept or modify WebSocket frames, consider using `WebSocketRoute`.
  class WebSocket < PlaywrightApi

    #
    # Indicates that the web socket has been closed.
    def closed?
      wrap_impl(@impl.closed?)
    end

    #
    # Contains the URL of the WebSocket.
    def url
      wrap_impl(@impl.url)
    end

    #
    # Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
    # value. Will throw an error if the webSocket is closed before the event is fired. Returns the event data value.
    def expect_event(event, predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_event(unwrap_impl(event), predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # **NOTE**: In most cases, you should use [`method: WebSocket.waitForEvent`].
    #
    # Waits for given `event` to fire. If predicate is provided, it passes
    # event's value into the `predicate` function and waits for `predicate(event)` to return a truthy value.
    # Will throw an error if the socket is closed before the `event` is fired.
    def wait_for_event(event, predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.wait_for_event(unwrap_impl(event), predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def once(event, callback)
      event_emitter_proxy.once(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def on(event, callback)
      event_emitter_proxy.on(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def off(event, callback)
      event_emitter_proxy.off(event, callback)
    end

    private def event_emitter_proxy
      @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)
    end
  end
end
