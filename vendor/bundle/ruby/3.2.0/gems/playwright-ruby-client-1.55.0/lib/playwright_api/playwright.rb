module Playwright
  #
  # Playwright module provides a method to launch a browser instance. The following is a typical example of using Playwright
  # to drive automation:
  #
  # ```python sync
  # from playwright.sync_api import sync_playwright, Playwright
  #
  # def run(playwright: Playwright):
  #     chromium = playwright.chromium # or "firefox" or "webkit".
  #     browser = chromium.launch()
  #     page = browser.new_page()
  #     page.goto("http://example.com")
  #     # other actions...
  #     browser.close()
  #
  # with sync_playwright() as playwright:
  #     run(playwright)
  # ```
  class Playwright < PlaywrightApi

    #
    # This object can be used to launch or connect to Chromium, returning instances of `Browser`.
    def chromium # property
      wrap_impl(@impl.chromium)
    end

    #
    # Returns a dictionary of devices to be used with [`method: Browser.newContext`] or [`method: Browser.newPage`].
    #
    # ```python sync
    # from playwright.sync_api import sync_playwright, Playwright
    #
    # def run(playwright: Playwright):
    #     webkit = playwright.webkit
    #     iphone = playwright.devices["iPhone 6"]
    #     browser = webkit.launch()
    #     context = browser.new_context(**iphone)
    #     page = context.new_page()
    #     page.goto("http://example.com")
    #     # other actions...
    #     browser.close()
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    def devices # property
      wrap_impl(@impl.devices)
    end

    #
    # This object can be used to launch or connect to Firefox, returning instances of `Browser`.
    def firefox # property
      wrap_impl(@impl.firefox)
    end

    #
    # Exposes API that can be used for the Web API testing.
    def request # property
      raise NotImplementedError.new('request is not implemented yet.')
    end

    #
    # Selectors can be used to install custom selector engines. See
    # [extensibility](../extensibility.md) for more information.
    def selectors # property
      wrap_impl(@impl.selectors)
    end

    #
    # This object can be used to launch or connect to WebKit, returning instances of `Browser`.
    def webkit # property
      wrap_impl(@impl.webkit)
    end

    #
    # Terminates this instance of Playwright in case it was created bypassing the Python context manager. This is useful in REPL applications.
    #
    # ```py
    # from playwright.sync_api import sync_playwright
    #
    # playwright = sync_playwright().start()
    #
    # browser = playwright.chromium.launch()
    # page = browser.new_page()
    # page.goto("https://playwright.dev/")
    # page.screenshot(path="example.png")
    # browser.close()
    #
    # playwright.stop()
    # ```
    def stop
      raise NotImplementedError.new('stop is not implemented yet.')
    end

    # @nodoc
    def android
      wrap_impl(@impl.android)
    end

    # @nodoc
    def electron
      wrap_impl(@impl.electron)
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
