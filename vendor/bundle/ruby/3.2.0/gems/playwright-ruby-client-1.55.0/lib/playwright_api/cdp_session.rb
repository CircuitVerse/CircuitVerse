module Playwright
  #
  # The `CDPSession` instances are used to talk raw Chrome Devtools Protocol:
  # - protocol methods can be called with `session.send` method.
  # - protocol events can be subscribed to with `session.on` method.
  #
  # Useful links:
  # - Documentation on DevTools Protocol can be found here: [DevTools Protocol Viewer](https://chromedevtools.github.io/devtools-protocol/).
  # - Getting Started with DevTools Protocol: https://github.com/aslushnikov/getting-started-with-cdp/blob/master/README.md
  #
  # ```python sync
  # client = page.context.new_cdp_session(page)
  # client.send("Animation.enable")
  # client.on("Animation.animationCreated", lambda: print("animation created!"))
  # response = client.send("Animation.getPlaybackRate")
  # print("playback rate is " + str(response["playbackRate"]))
  # client.send("Animation.setPlaybackRate", {
  #     "playbackRate": response["playbackRate"] / 2
  # })
  # ```
  class CDPSession < PlaywrightApi

    #
    # Detaches the CDPSession from the target. Once detached, the CDPSession object won't emit any events and can't be used to
    # send messages.
    def detach
      wrap_impl(@impl.detach)
    end

    def send_message(method, params: nil)
      wrap_impl(@impl.send_message(unwrap_impl(method), params: unwrap_impl(params)))
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
