module Playwright
  #
  # BrowserContexts provide a way to operate multiple independent browser sessions.
  #
  # If a page opens another page, e.g. with a `window.open` call, the popup will belong to the parent page's browser
  # context.
  #
  # Playwright allows creating isolated non-persistent browser contexts with [`method: Browser.newContext`] method. Non-persistent browser
  # contexts don't write any browsing data to disk.
  #
  # ```python sync
  # # create a new incognito browser context
  # context = browser.new_context()
  # # create a new page inside context.
  # page = context.new_page()
  # page.goto("https://example.com")
  # # dispose context once it is no longer needed.
  # context.close()
  # ```
  class BrowserContext < PlaywrightApi

    #
    # Playwright has ability to mock clock and passage of time.
    def clock # property
      wrap_impl(@impl.clock)
    end

    #
    # API testing helper associated with this context. Requests made with this API will use context cookies.
    def request # property
      wrap_impl(@impl.request)
    end

    def tracing # property
      wrap_impl(@impl.tracing)
    end

    #
    # Adds cookies into this browser context. All pages within this context will have these cookies installed. Cookies can be
    # obtained via [`method: BrowserContext.cookies`].
    #
    # **Usage**
    #
    # ```python sync
    # browser_context.add_cookies([cookie_object1, cookie_object2])
    # ```
    def add_cookies(cookies)
      wrap_impl(@impl.add_cookies(unwrap_impl(cookies)))
    end

    #
    # Adds a script which would be evaluated in one of the following scenarios:
    # - Whenever a page is created in the browser context or is navigated.
    # - Whenever a child frame is attached or navigated in any page in the browser context. In this case, the script is evaluated in the context of the newly attached frame.
    #
    # The script is evaluated after the document was created but before any of its scripts were run. This is useful to amend
    # the JavaScript environment, e.g. to seed `Math.random`.
    #
    # **Usage**
    #
    # An example of overriding `Math.random` before the page loads:
    #
    # ```python sync
    # # in your playwright script, assuming the preload.js file is in same directory.
    # browser_context.add_init_script(path="preload.js")
    # ```
    #
    # **NOTE**: The order of evaluation of multiple scripts installed via [`method: BrowserContext.addInitScript`] and
    # [`method: Page.addInitScript`] is not defined.
    def add_init_script(path: nil, script: nil)
      wrap_impl(@impl.add_init_script(path: unwrap_impl(path), script: unwrap_impl(script)))
    end

    #
    # **NOTE**: Background pages are only supported on Chromium-based browsers.
    #
    # All existing background pages in the context.
    def background_pages
      wrap_impl(@impl.background_pages)
    end

    #
    # Gets the browser instance that owns the context. Returns `null` if the context is created outside of normal browser, e.g. Android or Electron.
    def browser
      wrap_impl(@impl.browser)
    end

    #
    # Removes cookies from context. Accepts optional filter.
    #
    # **Usage**
    #
    # ```python sync
    # context.clear_cookies()
    # context.clear_cookies(name="session-id")
    # context.clear_cookies(domain="my-origin.com")
    # context.clear_cookies(path="/api/v1")
    # context.clear_cookies(name="session-id", domain="my-origin.com")
    # ```
    def clear_cookies(domain: nil, name: nil, path: nil)
      wrap_impl(@impl.clear_cookies(domain: unwrap_impl(domain), name: unwrap_impl(name), path: unwrap_impl(path)))
    end

    #
    # Clears all permission overrides for the browser context.
    #
    # **Usage**
    #
    # ```python sync
    # context = browser.new_context()
    # context.grant_permissions(["clipboard-read"])
    # # do stuff ..
    # context.clear_permissions()
    # ```
    def clear_permissions
      wrap_impl(@impl.clear_permissions)
    end

    #
    # Closes the browser context. All the pages that belong to the browser context will be closed.
    #
    # **NOTE**: The default browser context cannot be closed.
    def close(reason: nil)
      wrap_impl(@impl.close(reason: unwrap_impl(reason)))
    end

    #
    # If no URLs are specified, this method returns all cookies. If URLs are specified, only cookies that affect those URLs
    # are returned.
    def cookies(urls: nil)
      wrap_impl(@impl.cookies(urls: unwrap_impl(urls)))
    end

    #
    # The method adds a function called `name` on the `window` object of every frame in every page in the context.
    # When called, the function executes `callback` and returns a [Promise] which resolves to the return value of
    # `callback`. If the `callback` returns a [Promise], it will be awaited.
    #
    # The first argument of the `callback` function contains information about the caller: `{ browserContext:
    # BrowserContext, page: Page, frame: Frame }`.
    #
    # See [`method: Page.exposeBinding`] for page-only version.
    #
    # **Usage**
    #
    # An example of exposing page URL to all frames in all pages in the context:
    #
    # ```python sync
    # from playwright.sync_api import sync_playwright, Playwright
    #
    # def run(playwright: Playwright):
    #     webkit = playwright.webkit
    #     browser = webkit.launch(headless=False)
    #     context = browser.new_context()
    #     context.expose_binding("pageURL", lambda source: source["page"].url)
    #     page = context.new_page()
    #     page.set_content("""
    #     <script>
    #       async function onClick() {
    #         document.querySelector('div').textContent = await window.pageURL();
    #       }
    #     </script>
    #     <button onclick="onClick()">Click me</button>
    #     <div></div>
    #     """)
    #     page.get_by_role("button").click()
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    def expose_binding(name, callback, handle: nil)
      wrap_impl(@impl.expose_binding(unwrap_impl(name), unwrap_impl(callback), handle: unwrap_impl(handle)))
    end

    #
    # The method adds a function called `name` on the `window` object of every frame in every page in the context.
    # When called, the function executes `callback` and returns a [Promise] which resolves to the return value of
    # `callback`.
    #
    # If the `callback` returns a [Promise], it will be awaited.
    #
    # See [`method: Page.exposeFunction`] for page-only version.
    #
    # **Usage**
    #
    # An example of adding a `sha256` function to all pages in the context:
    #
    # ```python sync
    # import hashlib
    # from playwright.sync_api import sync_playwright
    #
    # def sha256(text: str) -> str:
    #     m = hashlib.sha256()
    #     m.update(bytes(text, "utf8"))
    #     return m.hexdigest()
    #
    #
    # def run(playwright: Playwright):
    #     webkit = playwright.webkit
    #     browser = webkit.launch(headless=False)
    #     context = browser.new_context()
    #     context.expose_function("sha256", sha256)
    #     page = context.new_page()
    #     page.set_content("""
    #         <script>
    #           async function onClick() {
    #             document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
    #           }
    #         </script>
    #         <button onclick="onClick()">Click me</button>
    #         <div></div>
    #     """)
    #     page.get_by_role("button").click()
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    def expose_function(name, callback)
      wrap_impl(@impl.expose_function(unwrap_impl(name), unwrap_impl(callback)))
    end

    #
    # Grants specified permissions to the browser context. Only grants corresponding permissions to the given origin if
    # specified.
    def grant_permissions(permissions, origin: nil)
      wrap_impl(@impl.grant_permissions(unwrap_impl(permissions), origin: unwrap_impl(origin)))
    end

    #
    # **NOTE**: CDP sessions are only supported on Chromium-based browsers.
    #
    # Returns the newly created session.
    def new_cdp_session(page)
      wrap_impl(@impl.new_cdp_session(unwrap_impl(page)))
    end

    #
    # Creates a new page in the browser context.
    def new_page(&block)
      wrap_impl(@impl.new_page(&wrap_block_call(block)))
    end

    #
    # Returns all open pages in the context.
    def pages
      wrap_impl(@impl.pages)
    end

    #
    # Routing provides the capability to modify network requests that are made by any page in the browser context. Once route
    # is enabled, every request matching the url pattern will stall unless it's continued, fulfilled or aborted.
    #
    # **NOTE**: [`method: BrowserContext.route`] will not intercept requests intercepted by Service Worker. See [this](https://github.com/microsoft/playwright/issues/1090) issue. We recommend disabling Service Workers when using request interception by setting `serviceWorkers` to `'block'`.
    #
    # **Usage**
    #
    # An example of a naive handler that aborts all image requests:
    #
    # ```python sync
    # context = browser.new_context()
    # page = context.new_page()
    # context.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
    # page.goto("https://example.com")
    # browser.close()
    # ```
    #
    # or the same snippet using a regex pattern instead:
    #
    # ```python sync
    # context = browser.new_context()
    # page = context.new_page()
    # context.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
    # page = await context.new_page()
    # page = context.new_page()
    # page.goto("https://example.com")
    # browser.close()
    # ```
    #
    # It is possible to examine the request to decide the route action. For example, mocking all requests that contain some post data, and leaving all other requests as is:
    #
    # ```python sync
    # def handle_route(route: Route):
    #   if ("my-string" in route.request.post_data):
    #     route.fulfill(body="mocked-data")
    #   else:
    #     route.continue_()
    # context.route("/api/**", handle_route)
    # ```
    #
    # Page routes (set up with [`method: Page.route`]) take precedence over browser context routes when request matches both
    # handlers.
    #
    # To remove a route with its handler you can use [`method: BrowserContext.unroute`].
    #
    # **NOTE**: Enabling routing disables http cache.
    def route(url, handler, times: nil)
      wrap_impl(@impl.route(unwrap_impl(url), unwrap_impl(handler), times: unwrap_impl(times)))
    end

    #
    # If specified the network requests that are made in the context will be served from the HAR file. Read more about [Replaying from HAR](../mock.md#replaying-from-har).
    #
    # Playwright will not serve requests intercepted by Service Worker from the HAR file. See [this](https://github.com/microsoft/playwright/issues/1090) issue. We recommend disabling Service Workers when using request interception by setting `serviceWorkers` to `'block'`.
    def route_from_har(
          har,
          notFound: nil,
          update: nil,
          updateContent: nil,
          updateMode: nil,
          url: nil)
      wrap_impl(@impl.route_from_har(unwrap_impl(har), notFound: unwrap_impl(notFound), update: unwrap_impl(update), updateContent: unwrap_impl(updateContent), updateMode: unwrap_impl(updateMode), url: unwrap_impl(url)))
    end

    #
    # This method allows to modify websocket connections that are made by any page in the browser context.
    #
    # Note that only `WebSocket`s created after this method was called will be routed. It is recommended to call this method before creating any pages.
    #
    # **Usage**
    #
    # Below is an example of a simple handler that blocks some websocket messages.
    # See `WebSocketRoute` for more details and examples.
    #
    # ```python sync
    # def message_handler(ws: WebSocketRoute, message: Union[str, bytes]):
    #   if message == "to-be-blocked":
    #     return
    #   ws.send(message)
    #
    # def handler(ws: WebSocketRoute):
    #   ws.route_send(lambda message: message_handler(ws, message))
    #   ws.connect()
    #
    # context.route_web_socket("/ws", handler)
    # ```
    def route_web_socket(url, handler)
      raise NotImplementedError.new('route_web_socket is not implemented yet.')
    end

    #
    # **NOTE**: Service workers are only supported on Chromium-based browsers.
    #
    # All existing service workers in the context.
    def service_workers
      wrap_impl(@impl.service_workers)
    end

    #
    # This setting will change the default maximum navigation time for the following methods and related shortcuts:
    # - [`method: Page.goBack`]
    # - [`method: Page.goForward`]
    # - [`method: Page.goto`]
    # - [`method: Page.reload`]
    # - [`method: Page.setContent`]
    # - [`method: Page.waitForNavigation`]
    #
    # **NOTE**: [`method: Page.setDefaultNavigationTimeout`] and [`method: Page.setDefaultTimeout`] take priority over
    # [`method: BrowserContext.setDefaultNavigationTimeout`].
    def set_default_navigation_timeout(timeout)
      wrap_impl(@impl.set_default_navigation_timeout(unwrap_impl(timeout)))
    end
    alias_method :default_navigation_timeout=, :set_default_navigation_timeout

    #
    # This setting will change the default maximum time for all the methods accepting `timeout` option.
    #
    # **NOTE**: [`method: Page.setDefaultNavigationTimeout`], [`method: Page.setDefaultTimeout`] and
    # [`method: BrowserContext.setDefaultNavigationTimeout`] take priority over [`method: BrowserContext.setDefaultTimeout`].
    def set_default_timeout(timeout)
      wrap_impl(@impl.set_default_timeout(unwrap_impl(timeout)))
    end
    alias_method :default_timeout=, :set_default_timeout

    #
    # The extra HTTP headers will be sent with every request initiated by any page in the context. These headers are merged
    # with page-specific extra HTTP headers set with [`method: Page.setExtraHTTPHeaders`]. If page overrides a particular
    # header, page-specific header value will be used instead of the browser context header value.
    #
    # **NOTE**: [`method: BrowserContext.setExtraHTTPHeaders`] does not guarantee the order of headers in the outgoing requests.
    def set_extra_http_headers(headers)
      wrap_impl(@impl.set_extra_http_headers(unwrap_impl(headers)))
    end
    alias_method :extra_http_headers=, :set_extra_http_headers

    #
    # Sets the context's geolocation. Passing `null` or `undefined` emulates position unavailable.
    #
    # **Usage**
    #
    # ```python sync
    # browser_context.set_geolocation({"latitude": 59.95, "longitude": 30.31667})
    # ```
    #
    # **NOTE**: Consider using [`method: BrowserContext.grantPermissions`] to grant permissions for the browser context pages to read
    # its geolocation.
    def set_geolocation(geolocation)
      wrap_impl(@impl.set_geolocation(unwrap_impl(geolocation)))
    end
    alias_method :geolocation=, :set_geolocation

    def set_offline(offline)
      wrap_impl(@impl.set_offline(unwrap_impl(offline)))
    end
    alias_method :offline=, :set_offline

    #
    # Returns storage state for this browser context, contains current cookies, local storage snapshot and IndexedDB snapshot.
    def storage_state(indexedDB: nil, path: nil)
      wrap_impl(@impl.storage_state(indexedDB: unwrap_impl(indexedDB), path: unwrap_impl(path)))
    end

    #
    # Removes all routes created with [`method: BrowserContext.route`] and [`method: BrowserContext.routeFromHAR`].
    def unroute_all(behavior: nil)
      wrap_impl(@impl.unroute_all(behavior: unwrap_impl(behavior)))
    end

    #
    # Removes a route created with [`method: BrowserContext.route`]. When `handler` is not specified, removes all
    # routes for the `url`.
    def unroute(url, handler: nil)
      wrap_impl(@impl.unroute(unwrap_impl(url), handler: unwrap_impl(handler)))
    end

    #
    # Performs action and waits for a `ConsoleMessage` to be logged by in the pages in the context. If predicate is provided, it passes
    # `ConsoleMessage` value into the `predicate` function and waits for `predicate(message)` to return a truthy value.
    # Will throw an error if the page is closed before the [`event: BrowserContext.console`] event is fired.
    def expect_console_message(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_console_message(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
    # value. Will throw an error if the context closes before the event is fired. Returns the event data value.
    #
    # **Usage**
    #
    # ```python sync
    # with context.expect_event("page") as event_info:
    #     page.get_by_role("button").click()
    # page = event_info.value
    # ```
    def expect_event(event, predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_event(unwrap_impl(event), predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Performs action and waits for a new `Page` to be created in the context. If predicate is provided, it passes
    # `Page` value into the `predicate` function and waits for `predicate(event)` to return a truthy value.
    # Will throw an error if the context closes before new `Page` is created.
    def expect_page(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_page(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # **NOTE**: In most cases, you should use [`method: BrowserContext.waitForEvent`].
    #
    # Waits for given `event` to fire. If predicate is provided, it passes
    # event's value into the `predicate` function and waits for `predicate(event)` to return a truthy value.
    # Will throw an error if the browser context is closed before the `event` is fired.
    def wait_for_event(event, predicate: nil, timeout: nil)
      raise NotImplementedError.new('wait_for_event is not implemented yet.')
    end

    # @nodoc
    def enable_debug_console!
      wrap_impl(@impl.enable_debug_console!)
    end

    # @nodoc
    def pause
      wrap_impl(@impl.pause)
    end

    # @nodoc
    def owner_page=(req)
      wrap_impl(@impl.owner_page=(unwrap_impl(req)))
    end

    # @nodoc
    def options=(req)
      wrap_impl(@impl.options=(unwrap_impl(req)))
    end

    # @nodoc
    def browser=(req)
      wrap_impl(@impl.browser=(unwrap_impl(req)))
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
