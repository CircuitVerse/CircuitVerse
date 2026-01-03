module Playwright
  #
  # Whenever the page sends a request for a network resource the following sequence of events are emitted by `Page`:
  # - [`event: Page.request`] emitted when the request is issued by the page.
  # - [`event: Page.response`] emitted when/if the response status and headers are received for the request.
  # - [`event: Page.requestFinished`] emitted when the response body is downloaded and the request is complete.
  #
  # If request fails at some point, then instead of `'requestfinished'` event (and possibly instead of 'response' event),
  # the  [`event: Page.requestFailed`] event is emitted.
  #
  # **NOTE**: HTTP Error responses, such as 404 or 503, are still successful responses from HTTP standpoint, so request will complete
  # with `'requestfinished'` event.
  #
  # If request gets a 'redirect' response, the request is successfully finished with the `requestfinished` event, and a new
  # request is  issued to a redirected url.
  class Request < PlaywrightApi

    #
    # An object with all the request HTTP headers associated with this request. The header names are lower-cased.
    def all_headers
      wrap_impl(@impl.all_headers)
    end

    #
    # The method returns `null` unless this request has failed, as reported by `requestfailed` event.
    #
    # **Usage**
    #
    # Example of logging of all the failed requests:
    #
    # ```py
    # page.on("requestfailed", lambda request: print(request.url + " " + request.failure))
    # ```
    def failure
      wrap_impl(@impl.failure)
    end

    #
    # Returns the `Frame` that initiated this request.
    #
    # **Usage**
    #
    # ```py
    # frame_url = request.frame.url
    # ```
    #
    # **Details**
    #
    # Note that in some cases the frame is not available, and this method will throw.
    # - When request originates in the Service Worker. You can use `request.serviceWorker()` to check that.
    # - When navigation request is issued before the corresponding frame is created. You can use [`method: Request.isNavigationRequest`] to check that.
    #
    # Here is an example that handles all the cases:
    def frame
      wrap_impl(@impl.frame)
    end

    #
    # An object with the request HTTP headers. The header names are lower-cased.
    # Note that this method does not return security-related headers, including cookie-related ones.
    # You can use [`method: Request.allHeaders`] for complete list of headers that include `cookie` information.
    def headers
      wrap_impl(@impl.headers)
    end

    #
    # An array with all the request HTTP headers associated with this request. Unlike [`method: Request.allHeaders`], header names are NOT lower-cased.
    # Headers with multiple entries, such as `Set-Cookie`, appear in the array multiple times.
    def headers_array
      wrap_impl(@impl.headers_array)
    end

    #
    # Returns the value of the header matching the name. The name is case-insensitive.
    def header_value(name)
      wrap_impl(@impl.header_value(unwrap_impl(name)))
    end

    #
    # Whether this request is driving frame's navigation.
    #
    # Some navigation requests are issued before the corresponding frame is created, and therefore
    # do not have [`method: Request.frame`] available.
    def navigation_request?
      wrap_impl(@impl.navigation_request?)
    end

    #
    # Request's method (GET, POST, etc.)
    def method
      wrap_impl(@impl.method)
    end

    #
    # Request's post body, if any.
    def post_data
      wrap_impl(@impl.post_data)
    end

    #
    # Request's post body in a binary form, if any.
    def post_data_buffer
      wrap_impl(@impl.post_data_buffer)
    end

    #
    # Returns parsed request's body for `form-urlencoded` and JSON as a fallback if any.
    #
    # When the response is `application/x-www-form-urlencoded` then a key/value object of the values will be returned.
    # Otherwise it will be parsed as JSON.
    def post_data_json
      wrap_impl(@impl.post_data_json)
    end

    #
    # Request that was redirected by the server to this one, if any.
    #
    # When the server responds with a redirect, Playwright creates a new `Request` object. The two requests are connected by
    # `redirectedFrom()` and `redirectedTo()` methods. When multiple server redirects has happened, it is possible to
    # construct the whole redirect chain by repeatedly calling `redirectedFrom()`.
    #
    # **Usage**
    #
    # For example, if the website `http://example.com` redirects to `https://example.com`:
    #
    # ```python sync
    # response = page.goto("http://example.com")
    # print(response.request.redirected_from.url) # "http://example.com"
    # ```
    #
    # If the website `https://google.com` has no redirects:
    #
    # ```python sync
    # response = page.goto("https://google.com")
    # print(response.request.redirected_from) # None
    # ```
    def redirected_from
      wrap_impl(@impl.redirected_from)
    end

    #
    # New request issued by the browser if the server responded with redirect.
    #
    # **Usage**
    #
    # This method is the opposite of [`method: Request.redirectedFrom`]:
    #
    # ```py
    # assert request.redirected_from.redirected_to == request
    # ```
    def redirected_to
      wrap_impl(@impl.redirected_to)
    end

    #
    # Contains the request's resource type as it was perceived by the rendering engine. ResourceType will be one of the
    # following: `document`, `stylesheet`, `image`, `media`, `font`, `script`, `texttrack`, `xhr`, `fetch`, `eventsource`,
    # `websocket`, `manifest`, `other`.
    def resource_type
      wrap_impl(@impl.resource_type)
    end

    #
    # Returns the matching `Response` object, or `null` if the response was not received due to error.
    def response
      wrap_impl(@impl.response)
    end

    #
    # Returns resource size information for given request.
    def sizes
      wrap_impl(@impl.sizes)
    end

    #
    # Returns resource timing information for given request. Most of the timing values become available upon the response,
    # `responseEnd` becomes available when request finishes. Find more information at
    # [Resource Timing API](https://developer.mozilla.org/en-US/docs/Web/API/PerformanceResourceTiming).
    #
    # **Usage**
    #
    # ```python sync
    # with page.expect_event("requestfinished") as request_info:
    #     page.goto("http://example.com")
    # request = request_info.value
    # print(request.timing)
    # ```
    def timing
      wrap_impl(@impl.timing)
    end

    #
    # URL of the request.
    def url
      wrap_impl(@impl.url)
    end

    # @nodoc
    def apply_fallback_overrides(overrides)
      wrap_impl(@impl.apply_fallback_overrides(unwrap_impl(overrides)))
    end

    # @nodoc
    def header_values(name)
      wrap_impl(@impl.header_values(unwrap_impl(name)))
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
