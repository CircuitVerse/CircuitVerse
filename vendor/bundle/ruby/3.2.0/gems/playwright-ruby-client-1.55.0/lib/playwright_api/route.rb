module Playwright
  #
  # Whenever a network route is set up with [`method: Page.route`] or [`method: BrowserContext.route`], the `Route` object
  # allows to handle the route.
  #
  # Learn more about [networking](../network.md).
  class Route < PlaywrightApi

    #
    # Aborts the route's request.
    def abort(errorCode: nil)
      wrap_impl(@impl.abort(errorCode: unwrap_impl(errorCode)))
    end

    #
    # Sends route's request to the network with optional overrides.
    #
    # **Usage**
    #
    # ```python sync
    # def handle(route, request):
    #     # override headers
    #     headers = {
    #         **request.headers,
    #         "foo": "foo-value", # set "foo" header
    #         "bar": None # remove "bar" header
    #     }
    #     route.continue_(headers=headers)
    #
    # page.route("**/*", handle)
    # ```
    #
    # **Details**
    #
    # The `headers` option applies to both the routed request and any redirects it initiates. However, `url`, `method`, and `postData` only apply to the original request and are not carried over to redirected requests.
    #
    # [`method: Route.continue`] will immediately send the request to the network, other matching handlers won't be invoked. Use [`method: Route.fallback`] If you want next matching handler in the chain to be invoked.
    #
    # **NOTE**: The `Cookie` header cannot be overridden using this method. If a value is provided, it will be ignored, and the cookie will be loaded from the browser's cookie store. To set custom cookies, use [`method: BrowserContext.addCookies`].
    def continue(headers: nil, method: nil, postData: nil, url: nil)
      wrap_impl(@impl.continue(headers: unwrap_impl(headers), method: unwrap_impl(method), postData: unwrap_impl(postData), url: unwrap_impl(url)))
    end

    #
    # Continues route's request with optional overrides. The method is similar to [`method: Route.continue`] with the difference that other matching handlers will be invoked before sending the request.
    #
    # **Usage**
    #
    # When several routes match the given pattern, they run in the order opposite to their registration.
    # That way the last registered route can always override all the previous ones. In the example below,
    # request will be handled by the bottom-most handler first, then it'll fall back to the previous one and
    # in the end will be aborted by the first registered route.
    #
    # ```python sync
    # page.route("**/*", lambda route: route.abort())  # Runs last.
    # page.route("**/*", lambda route: route.fallback())  # Runs second.
    # page.route("**/*", lambda route: route.fallback())  # Runs first.
    # ```
    #
    # Registering multiple routes is useful when you want separate handlers to
    # handle different kinds of requests, for example API calls vs page resources or
    # GET requests vs POST requests as in the example below.
    #
    # ```python sync
    # # Handle GET requests.
    # def handle_get(route):
    #     if route.request.method != "GET":
    #         route.fallback()
    #         return
    #   # Handling GET only.
    #   # ...
    #
    # # Handle POST requests.
    # def handle_post(route):
    #     if route.request.method != "POST":
    #         route.fallback()
    #         return
    #   # Handling POST only.
    #   # ...
    #
    # page.route("**/*", handle_get)
    # page.route("**/*", handle_post)
    # ```
    #
    # One can also modify request while falling back to the subsequent handler, that way intermediate
    # route handler can modify url, method, headers and postData of the request.
    #
    # ```python sync
    # def handle(route, request):
    #     # override headers
    #     headers = {
    #         **request.headers,
    #         "foo": "foo-value", # set "foo" header
    #         "bar": None # remove "bar" header
    #     }
    #     route.fallback(headers=headers)
    #
    # page.route("**/*", handle)
    # ```
    #
    # Use [`method: Route.continue`] to immediately send the request to the network, other matching handlers won't be invoked in that case.
    def fallback(headers: nil, method: nil, postData: nil, url: nil)
      wrap_impl(@impl.fallback(headers: unwrap_impl(headers), method: unwrap_impl(method), postData: unwrap_impl(postData), url: unwrap_impl(url)))
    end

    #
    # Performs the request and fetches result without fulfilling it, so that the response
    # could be modified and then fulfilled.
    #
    # **Usage**
    #
    # ```python sync
    # def handle(route):
    #     response = route.fetch()
    #     json = response.json()
    #     json["message"]["big_red_dog"] = []
    #     route.fulfill(response=response, json=json)
    #
    # page.route("https://dog.ceo/api/breeds/list/all", handle)
    # ```
    #
    # **Details**
    #
    # Note that `headers` option will apply to the fetched request as well as any redirects initiated by it. If you want to only apply `headers` to the original request, but not to redirects, look into [`method: Route.continue`] instead.
    def fetch(
          headers: nil,
          maxRedirects: nil,
          maxRetries: nil,
          method: nil,
          postData: nil,
          timeout: nil,
          url: nil)
      wrap_impl(@impl.fetch(headers: unwrap_impl(headers), maxRedirects: unwrap_impl(maxRedirects), maxRetries: unwrap_impl(maxRetries), method: unwrap_impl(method), postData: unwrap_impl(postData), timeout: unwrap_impl(timeout), url: unwrap_impl(url)))
    end

    #
    # Fulfills route's request with given response.
    #
    # **Usage**
    #
    # An example of fulfilling all requests with 404 responses:
    #
    # ```python sync
    # page.route("**/*", lambda route: route.fulfill(
    #     status=404,
    #     content_type="text/plain",
    #     body="not found!"))
    # ```
    #
    # An example of serving static file:
    #
    # ```python sync
    # page.route("**/xhr_endpoint", lambda route: route.fulfill(path="mock_data.json"))
    # ```
    def fulfill(
          body: nil,
          contentType: nil,
          headers: nil,
          json: nil,
          path: nil,
          response: nil,
          status: nil)
      wrap_impl(@impl.fulfill(body: unwrap_impl(body), contentType: unwrap_impl(contentType), headers: unwrap_impl(headers), json: unwrap_impl(json), path: unwrap_impl(path), response: unwrap_impl(response), status: unwrap_impl(status)))
    end

    #
    # A request to be routed.
    def request
      wrap_impl(@impl.request)
    end

    # @nodoc
    def redirect_navigation_request(url)
      wrap_impl(@impl.redirect_navigation_request(unwrap_impl(url)))
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
