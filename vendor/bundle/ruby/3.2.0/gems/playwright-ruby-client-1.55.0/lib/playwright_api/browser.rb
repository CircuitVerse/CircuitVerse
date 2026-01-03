module Playwright
  #
  # A Browser is created via [`method: BrowserType.launch`]. An example of using a `Browser` to create a `Page`:
  #
  # ```python sync
  # from playwright.sync_api import sync_playwright, Playwright
  #
  # def run(playwright: Playwright):
  #     firefox = playwright.firefox
  #     browser = firefox.launch()
  #     page = browser.new_page()
  #     page.goto("https://example.com")
  #     browser.close()
  #
  # with sync_playwright() as playwright:
  #     run(playwright)
  # ```
  class Browser < PlaywrightApi

    #
    # Get the browser type (chromium, firefox or webkit) that the browser belongs to.
    def browser_type
      wrap_impl(@impl.browser_type)
    end

    #
    # In case this browser is obtained using [`method: BrowserType.launch`], closes the browser and all of its pages (if any
    # were opened).
    #
    # In case this browser is connected to, clears all created contexts belonging to this browser and disconnects from the
    # browser server.
    #
    # **NOTE**: This is similar to force-quitting the browser. To close pages gracefully and ensure you receive page close events, call [`method: BrowserContext.close`] on any `BrowserContext` instances you explicitly created earlier using [`method: Browser.newContext`] **before** calling [`method: Browser.close`].
    #
    # The `Browser` object itself is considered to be disposed and cannot be used anymore.
    def close(reason: nil)
      wrap_impl(@impl.close(reason: unwrap_impl(reason)))
    end

    #
    # Returns an array of all open browser contexts. In a newly created browser, this will return zero browser contexts.
    #
    # **Usage**
    #
    # ```python sync
    # browser = pw.webkit.launch()
    # print(len(browser.contexts)) # prints `0`
    # context = browser.new_context()
    # print(len(browser.contexts)) # prints `1`
    # ```
    def contexts
      wrap_impl(@impl.contexts)
    end

    #
    # Indicates that the browser is connected.
    def connected?
      wrap_impl(@impl.connected?)
    end

    #
    # **NOTE**: CDP Sessions are only supported on Chromium-based browsers.
    #
    # Returns the newly created browser session.
    def new_browser_cdp_session
      wrap_impl(@impl.new_browser_cdp_session)
    end

    #
    # Creates a new browser context. It won't share cookies/cache with other browser contexts.
    #
    # **NOTE**: If directly using this method to create `BrowserContext`s, it is best practice to explicitly close the returned context via [`method: BrowserContext.close`] when your code is done with the `BrowserContext`,
    # and before calling [`method: Browser.close`]. This will ensure the `context` is closed gracefully and any artifacts—like HARs and videos—are fully flushed and saved.
    #
    # **Usage**
    #
    # ```python sync
    # browser = playwright.firefox.launch() # or "chromium" or "webkit".
    # # create a new incognito browser context.
    # context = browser.new_context()
    # # create a new page in a pristine context.
    # page = context.new_page()
    # page.goto("https://example.com")
    #
    # # gracefully close up everything
    # context.close()
    # browser.close()
    # ```
    def new_context(
          acceptDownloads: nil,
          baseURL: nil,
          bypassCSP: nil,
          clientCertificates: nil,
          colorScheme: nil,
          contrast: nil,
          deviceScaleFactor: nil,
          extraHTTPHeaders: nil,
          forcedColors: nil,
          geolocation: nil,
          hasTouch: nil,
          httpCredentials: nil,
          ignoreHTTPSErrors: nil,
          isMobile: nil,
          javaScriptEnabled: nil,
          locale: nil,
          noViewport: nil,
          offline: nil,
          permissions: nil,
          proxy: nil,
          record_har_content: nil,
          record_har_mode: nil,
          record_har_omit_content: nil,
          record_har_path: nil,
          record_har_url_filter: nil,
          record_video_dir: nil,
          record_video_size: nil,
          reducedMotion: nil,
          screen: nil,
          serviceWorkers: nil,
          storageState: nil,
          strictSelectors: nil,
          timezoneId: nil,
          userAgent: nil,
          viewport: nil,
          &block)
      wrap_impl(@impl.new_context(acceptDownloads: unwrap_impl(acceptDownloads), baseURL: unwrap_impl(baseURL), bypassCSP: unwrap_impl(bypassCSP), clientCertificates: unwrap_impl(clientCertificates), colorScheme: unwrap_impl(colorScheme), contrast: unwrap_impl(contrast), deviceScaleFactor: unwrap_impl(deviceScaleFactor), extraHTTPHeaders: unwrap_impl(extraHTTPHeaders), forcedColors: unwrap_impl(forcedColors), geolocation: unwrap_impl(geolocation), hasTouch: unwrap_impl(hasTouch), httpCredentials: unwrap_impl(httpCredentials), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), isMobile: unwrap_impl(isMobile), javaScriptEnabled: unwrap_impl(javaScriptEnabled), locale: unwrap_impl(locale), noViewport: unwrap_impl(noViewport), offline: unwrap_impl(offline), permissions: unwrap_impl(permissions), proxy: unwrap_impl(proxy), record_har_content: unwrap_impl(record_har_content), record_har_mode: unwrap_impl(record_har_mode), record_har_omit_content: unwrap_impl(record_har_omit_content), record_har_path: unwrap_impl(record_har_path), record_har_url_filter: unwrap_impl(record_har_url_filter), record_video_dir: unwrap_impl(record_video_dir), record_video_size: unwrap_impl(record_video_size), reducedMotion: unwrap_impl(reducedMotion), screen: unwrap_impl(screen), serviceWorkers: unwrap_impl(serviceWorkers), storageState: unwrap_impl(storageState), strictSelectors: unwrap_impl(strictSelectors), timezoneId: unwrap_impl(timezoneId), userAgent: unwrap_impl(userAgent), viewport: unwrap_impl(viewport), &wrap_block_call(block)))
    end

    #
    # Creates a new page in a new browser context. Closing this page will close the context as well.
    #
    # This is a convenience API that should only be used for the single-page scenarios and short snippets. Production code and
    # testing frameworks should explicitly create [`method: Browser.newContext`] followed by the
    # [`method: BrowserContext.newPage`] to control their exact life times.
    def new_page(
          acceptDownloads: nil,
          baseURL: nil,
          bypassCSP: nil,
          clientCertificates: nil,
          colorScheme: nil,
          contrast: nil,
          deviceScaleFactor: nil,
          extraHTTPHeaders: nil,
          forcedColors: nil,
          geolocation: nil,
          hasTouch: nil,
          httpCredentials: nil,
          ignoreHTTPSErrors: nil,
          isMobile: nil,
          javaScriptEnabled: nil,
          locale: nil,
          noViewport: nil,
          offline: nil,
          permissions: nil,
          proxy: nil,
          record_har_content: nil,
          record_har_mode: nil,
          record_har_omit_content: nil,
          record_har_path: nil,
          record_har_url_filter: nil,
          record_video_dir: nil,
          record_video_size: nil,
          reducedMotion: nil,
          screen: nil,
          serviceWorkers: nil,
          storageState: nil,
          strictSelectors: nil,
          timezoneId: nil,
          userAgent: nil,
          viewport: nil,
          &block)
      wrap_impl(@impl.new_page(acceptDownloads: unwrap_impl(acceptDownloads), baseURL: unwrap_impl(baseURL), bypassCSP: unwrap_impl(bypassCSP), clientCertificates: unwrap_impl(clientCertificates), colorScheme: unwrap_impl(colorScheme), contrast: unwrap_impl(contrast), deviceScaleFactor: unwrap_impl(deviceScaleFactor), extraHTTPHeaders: unwrap_impl(extraHTTPHeaders), forcedColors: unwrap_impl(forcedColors), geolocation: unwrap_impl(geolocation), hasTouch: unwrap_impl(hasTouch), httpCredentials: unwrap_impl(httpCredentials), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), isMobile: unwrap_impl(isMobile), javaScriptEnabled: unwrap_impl(javaScriptEnabled), locale: unwrap_impl(locale), noViewport: unwrap_impl(noViewport), offline: unwrap_impl(offline), permissions: unwrap_impl(permissions), proxy: unwrap_impl(proxy), record_har_content: unwrap_impl(record_har_content), record_har_mode: unwrap_impl(record_har_mode), record_har_omit_content: unwrap_impl(record_har_omit_content), record_har_path: unwrap_impl(record_har_path), record_har_url_filter: unwrap_impl(record_har_url_filter), record_video_dir: unwrap_impl(record_video_dir), record_video_size: unwrap_impl(record_video_size), reducedMotion: unwrap_impl(reducedMotion), screen: unwrap_impl(screen), serviceWorkers: unwrap_impl(serviceWorkers), storageState: unwrap_impl(storageState), strictSelectors: unwrap_impl(strictSelectors), timezoneId: unwrap_impl(timezoneId), userAgent: unwrap_impl(userAgent), viewport: unwrap_impl(viewport), &wrap_block_call(block)))
    end

    #
    # **NOTE**: This API controls [Chromium Tracing](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool) which is a low-level chromium-specific debugging tool. API to control [Playwright Tracing](../trace-viewer) could be found [here](./class-tracing).
    #
    # You can use [`method: Browser.startTracing`] and [`method: Browser.stopTracing`] to create a trace file that can
    # be opened in Chrome DevTools performance panel.
    #
    # **Usage**
    #
    # ```python sync
    # browser.start_tracing(page, path="trace.json")
    # page.goto("https://www.google.com")
    # browser.stop_tracing()
    # ```
    def start_tracing(page: nil, categories: nil, path: nil, screenshots: nil)
      wrap_impl(@impl.start_tracing(page: unwrap_impl(page), categories: unwrap_impl(categories), path: unwrap_impl(path), screenshots: unwrap_impl(screenshots)))
    end

    #
    # **NOTE**: This API controls [Chromium Tracing](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool) which is a low-level chromium-specific debugging tool. API to control [Playwright Tracing](../trace-viewer) could be found [here](./class-tracing).
    #
    # Returns the buffer with trace data.
    def stop_tracing
      wrap_impl(@impl.stop_tracing)
    end

    #
    # Returns the browser version.
    def version
      wrap_impl(@impl.version)
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
