module Playwright
  #
  # BrowserType provides methods to launch a specific browser instance or connect to an existing one. The following is a
  # typical example of using Playwright to drive automation:
  #
  # ```python sync
  # from playwright.sync_api import sync_playwright, Playwright
  #
  # def run(playwright: Playwright):
  #     chromium = playwright.chromium
  #     browser = chromium.launch()
  #     page = browser.new_page()
  #     page.goto("https://example.com")
  #     # other actions...
  #     browser.close()
  #
  # with sync_playwright() as playwright:
  #     run(playwright)
  # ```
  class BrowserType < PlaywrightApi

    #
    # This method attaches Playwright to an existing browser instance created via `BrowserType.launchServer` in Node.js.
    #
    # **NOTE**: The major and minor version of the Playwright instance that connects needs to match the version of Playwright that launches the browser (1.2.3 → is compatible with 1.2.x).
    def connect(
          wsEndpoint,
          exposeNetwork: nil,
          headers: nil,
          slowMo: nil,
          timeout: nil)
      raise NotImplementedError.new('connect is not implemented yet.')
    end

    #
    # This method attaches Playwright to an existing browser instance using the Chrome DevTools Protocol.
    #
    # The default browser context is accessible via [`method: Browser.contexts`].
    #
    # **NOTE**: Connecting over the Chrome DevTools Protocol is only supported for Chromium-based browsers.
    #
    # **NOTE**: This connection is significantly lower fidelity than the Playwright protocol connection via [`method: BrowserType.connect`]. If you are experiencing issues or attempting to use advanced functionality, you probably want to use [`method: BrowserType.connect`].
    #
    # **Usage**
    #
    # ```python sync
    # browser = playwright.chromium.connect_over_cdp("http://localhost:9222")
    # default_context = browser.contexts[0]
    # page = default_context.pages[0]
    # ```
    def connect_over_cdp(
          endpointURL,
          headers: nil,
          slowMo: nil,
          timeout: nil,
          &block)
      wrap_impl(@impl.connect_over_cdp(unwrap_impl(endpointURL), headers: unwrap_impl(headers), slowMo: unwrap_impl(slowMo), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # A path where Playwright expects to find a bundled browser executable.
    def executable_path
      wrap_impl(@impl.executable_path)
    end

    #
    # Returns the browser instance.
    #
    # **Usage**
    #
    # You can use `ignoreDefaultArgs` to filter out `--mute-audio` from default arguments:
    #
    # ```python sync
    # browser = playwright.chromium.launch( # or "firefox" or "webkit".
    #     ignore_default_args=["--mute-audio"]
    # )
    # ```
    #
    # > **Chromium-only** Playwright can also be used to control the Google Chrome or Microsoft Edge browsers, but it works best with the version of
    # Chromium it is bundled with. There is no guarantee it will work with any other version. Use `executablePath`
    # option with extreme caution.
    #
    # >
    #
    # > If Google Chrome (rather than Chromium) is preferred, a
    # [Chrome Canary](https://www.google.com/chrome/browser/canary.html) or
    # [Dev Channel](https://www.chromium.org/getting-involved/dev-channel) build is suggested.
    #
    # >
    #
    # > Stock browsers like Google Chrome and Microsoft Edge are suitable for tests that require proprietary media codecs for video playback. See [this article](https://www.howtogeek.com/202825/what%E2%80%99s-the-difference-between-chromium-and-chrome/) for other differences between Chromium and Chrome.
    # [This article](https://chromium.googlesource.com/chromium/src/+/lkgr/docs/chromium_browser_vs_google_chrome.md)
    # describes some differences for Linux users.
    def launch(
          args: nil,
          channel: nil,
          chromiumSandbox: nil,
          devtools: nil,
          downloadsPath: nil,
          env: nil,
          executablePath: nil,
          firefoxUserPrefs: nil,
          handleSIGHUP: nil,
          handleSIGINT: nil,
          handleSIGTERM: nil,
          headless: nil,
          ignoreDefaultArgs: nil,
          proxy: nil,
          slowMo: nil,
          timeout: nil,
          tracesDir: nil,
          &block)
      wrap_impl(@impl.launch(args: unwrap_impl(args), channel: unwrap_impl(channel), chromiumSandbox: unwrap_impl(chromiumSandbox), devtools: unwrap_impl(devtools), downloadsPath: unwrap_impl(downloadsPath), env: unwrap_impl(env), executablePath: unwrap_impl(executablePath), firefoxUserPrefs: unwrap_impl(firefoxUserPrefs), handleSIGHUP: unwrap_impl(handleSIGHUP), handleSIGINT: unwrap_impl(handleSIGINT), handleSIGTERM: unwrap_impl(handleSIGTERM), headless: unwrap_impl(headless), ignoreDefaultArgs: unwrap_impl(ignoreDefaultArgs), proxy: unwrap_impl(proxy), slowMo: unwrap_impl(slowMo), timeout: unwrap_impl(timeout), tracesDir: unwrap_impl(tracesDir), &wrap_block_call(block)))
    end

    #
    # Returns the persistent browser context instance.
    #
    # Launches browser that uses persistent storage located at `userDataDir` and returns the only context. Closing
    # this context will automatically close the browser.
    def launch_persistent_context(
          userDataDir,
          acceptDownloads: nil,
          args: nil,
          baseURL: nil,
          bypassCSP: nil,
          channel: nil,
          chromiumSandbox: nil,
          clientCertificates: nil,
          colorScheme: nil,
          contrast: nil,
          deviceScaleFactor: nil,
          devtools: nil,
          downloadsPath: nil,
          env: nil,
          executablePath: nil,
          extraHTTPHeaders: nil,
          firefoxUserPrefs: nil,
          forcedColors: nil,
          geolocation: nil,
          handleSIGHUP: nil,
          handleSIGINT: nil,
          handleSIGTERM: nil,
          hasTouch: nil,
          headless: nil,
          httpCredentials: nil,
          ignoreDefaultArgs: nil,
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
          slowMo: nil,
          strictSelectors: nil,
          timeout: nil,
          timezoneId: nil,
          tracesDir: nil,
          userAgent: nil,
          viewport: nil,
          &block)
      wrap_impl(@impl.launch_persistent_context(unwrap_impl(userDataDir), acceptDownloads: unwrap_impl(acceptDownloads), args: unwrap_impl(args), baseURL: unwrap_impl(baseURL), bypassCSP: unwrap_impl(bypassCSP), channel: unwrap_impl(channel), chromiumSandbox: unwrap_impl(chromiumSandbox), clientCertificates: unwrap_impl(clientCertificates), colorScheme: unwrap_impl(colorScheme), contrast: unwrap_impl(contrast), deviceScaleFactor: unwrap_impl(deviceScaleFactor), devtools: unwrap_impl(devtools), downloadsPath: unwrap_impl(downloadsPath), env: unwrap_impl(env), executablePath: unwrap_impl(executablePath), extraHTTPHeaders: unwrap_impl(extraHTTPHeaders), firefoxUserPrefs: unwrap_impl(firefoxUserPrefs), forcedColors: unwrap_impl(forcedColors), geolocation: unwrap_impl(geolocation), handleSIGHUP: unwrap_impl(handleSIGHUP), handleSIGINT: unwrap_impl(handleSIGINT), handleSIGTERM: unwrap_impl(handleSIGTERM), hasTouch: unwrap_impl(hasTouch), headless: unwrap_impl(headless), httpCredentials: unwrap_impl(httpCredentials), ignoreDefaultArgs: unwrap_impl(ignoreDefaultArgs), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), isMobile: unwrap_impl(isMobile), javaScriptEnabled: unwrap_impl(javaScriptEnabled), locale: unwrap_impl(locale), noViewport: unwrap_impl(noViewport), offline: unwrap_impl(offline), permissions: unwrap_impl(permissions), proxy: unwrap_impl(proxy), record_har_content: unwrap_impl(record_har_content), record_har_mode: unwrap_impl(record_har_mode), record_har_omit_content: unwrap_impl(record_har_omit_content), record_har_path: unwrap_impl(record_har_path), record_har_url_filter: unwrap_impl(record_har_url_filter), record_video_dir: unwrap_impl(record_video_dir), record_video_size: unwrap_impl(record_video_size), reducedMotion: unwrap_impl(reducedMotion), screen: unwrap_impl(screen), serviceWorkers: unwrap_impl(serviceWorkers), slowMo: unwrap_impl(slowMo), strictSelectors: unwrap_impl(strictSelectors), timeout: unwrap_impl(timeout), timezoneId: unwrap_impl(timezoneId), tracesDir: unwrap_impl(tracesDir), userAgent: unwrap_impl(userAgent), viewport: unwrap_impl(viewport), &wrap_block_call(block)))
    end

    #
    # Returns browser name. For example: `'chromium'`, `'webkit'` or `'firefox'`.
    def name
      wrap_impl(@impl.name)
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
