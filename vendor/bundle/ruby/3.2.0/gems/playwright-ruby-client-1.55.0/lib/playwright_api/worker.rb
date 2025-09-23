module Playwright
  #
  # The Worker class represents a [WebWorker](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API). `worker`
  # event is emitted on the page object to signal a worker creation. `close` event is emitted on the worker object when the
  # worker is gone.
  #
  # ```py
  # def handle_worker(worker):
  #     print("worker created: " + worker.url)
  #     worker.on("close", lambda: print("worker destroyed: " + worker.url))
  #
  # page.on('worker', handle_worker)
  #
  # print("current workers:")
  # for worker in page.workers:
  #     print("    " + worker.url)
  # ```
  class Worker < PlaywrightApi

    #
    # Returns the return value of `expression`.
    #
    # If the function passed to the [`method: Worker.evaluate`] returns a [Promise], then [`method: Worker.evaluate`] would wait for the promise
    # to resolve and return its value.
    #
    # If the function passed to the [`method: Worker.evaluate`] returns a non-[Serializable] value, then [`method: Worker.evaluate`] returns `undefined`. Playwright also supports transferring some
    # additional values that are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.
    def evaluate(expression, arg: nil)
      wrap_impl(@impl.evaluate(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    #
    # Returns the return value of `expression` as a `JSHandle`.
    #
    # The only difference between [`method: Worker.evaluate`] and
    # [`method: Worker.evaluateHandle`] is that [`method: Worker.evaluateHandle`]
    # returns `JSHandle`.
    #
    # If the function passed to the [`method: Worker.evaluateHandle`] returns a [Promise], then [`method: Worker.evaluateHandle`] would wait for
    # the promise to resolve and return its value.
    def evaluate_handle(expression, arg: nil)
      wrap_impl(@impl.evaluate_handle(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    def url
      wrap_impl(@impl.url)
    end

    # @nodoc
    def page=(req)
      wrap_impl(@impl.page=(unwrap_impl(req)))
    end

    # @nodoc
    def context=(req)
      wrap_impl(@impl.context=(unwrap_impl(req)))
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
