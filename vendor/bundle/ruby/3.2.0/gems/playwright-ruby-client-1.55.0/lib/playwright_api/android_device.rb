module Playwright
  #
  # `AndroidDevice` represents a connected device, either real hardware or emulated. Devices can be obtained using [`method: Android.devices`].
  class AndroidDevice < PlaywrightApi

    def input # property
      wrap_impl(@impl.input)
    end

    #
    # Disconnects from the device.
    def close
      wrap_impl(@impl.close)
    end

    #
    # Drags the widget defined by `selector` towards `dest` point.
    def drag(selector, dest, speed: nil)
      raise NotImplementedError.new('drag is not implemented yet.')
    end

    #
    # Fills the specific `selector` input box with `text`.
    def fill(selector, text)
      raise NotImplementedError.new('fill is not implemented yet.')
    end

    #
    # Flings the widget defined by `selector` in  the specified `direction`.
    def fling(selector, direction, speed: nil)
      raise NotImplementedError.new('fling is not implemented yet.')
    end

    #
    # Returns information about a widget defined by `selector`.
    def info(selector)
      wrap_impl(@impl.info(unwrap_impl(selector)))
    end

    #
    # Installs an apk on the device.
    def install_apk(file, args: nil)
      raise NotImplementedError.new('install_apk is not implemented yet.')
    end

    #
    # Launches Chrome browser on the device, and returns its persistent context.
    def launch_browser(
          acceptDownloads: nil,
          args: nil,
          baseURL: nil,
          bypassCSP: nil,
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
          pkg: nil,
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
          strictSelectors: nil,
          timezoneId: nil,
          userAgent: nil,
          viewport: nil,
          &block)
      wrap_impl(@impl.launch_browser(acceptDownloads: unwrap_impl(acceptDownloads), args: unwrap_impl(args), baseURL: unwrap_impl(baseURL), bypassCSP: unwrap_impl(bypassCSP), colorScheme: unwrap_impl(colorScheme), contrast: unwrap_impl(contrast), deviceScaleFactor: unwrap_impl(deviceScaleFactor), extraHTTPHeaders: unwrap_impl(extraHTTPHeaders), forcedColors: unwrap_impl(forcedColors), geolocation: unwrap_impl(geolocation), hasTouch: unwrap_impl(hasTouch), httpCredentials: unwrap_impl(httpCredentials), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), isMobile: unwrap_impl(isMobile), javaScriptEnabled: unwrap_impl(javaScriptEnabled), locale: unwrap_impl(locale), noViewport: unwrap_impl(noViewport), offline: unwrap_impl(offline), permissions: unwrap_impl(permissions), pkg: unwrap_impl(pkg), proxy: unwrap_impl(proxy), record_har_content: unwrap_impl(record_har_content), record_har_mode: unwrap_impl(record_har_mode), record_har_omit_content: unwrap_impl(record_har_omit_content), record_har_path: unwrap_impl(record_har_path), record_har_url_filter: unwrap_impl(record_har_url_filter), record_video_dir: unwrap_impl(record_video_dir), record_video_size: unwrap_impl(record_video_size), reducedMotion: unwrap_impl(reducedMotion), screen: unwrap_impl(screen), serviceWorkers: unwrap_impl(serviceWorkers), strictSelectors: unwrap_impl(strictSelectors), timezoneId: unwrap_impl(timezoneId), userAgent: unwrap_impl(userAgent), viewport: unwrap_impl(viewport), &wrap_block_call(block)))
    end

    #
    # Performs a long tap on the widget defined by `selector`.
    def long_tap(selector)
      raise NotImplementedError.new('long_tap is not implemented yet.')
    end

    #
    # Device model.
    def model
      wrap_impl(@impl.model)
    end

    #
    # Launches a process in the shell on the device and returns a socket to communicate with the launched process.
    def open(command)
      raise NotImplementedError.new('open is not implemented yet.')
    end

    #
    # Pinches the widget defined by `selector` in the closing direction.
    def pinch_close(selector, percent, speed: nil)
      raise NotImplementedError.new('pinch_close is not implemented yet.')
    end

    #
    # Pinches the widget defined by `selector` in the open direction.
    def pinch_open(selector, percent, speed: nil)
      raise NotImplementedError.new('pinch_open is not implemented yet.')
    end

    #
    # Presses the specific `key` in the widget defined by `selector`.
    def press(selector, key)
      raise NotImplementedError.new('press is not implemented yet.')
    end

    #
    # Copies a file to the device.
    def push(file, path, mode: nil)
      raise NotImplementedError.new('push is not implemented yet.')
    end

    #
    # Returns the buffer with the captured screenshot of the device.
    def screenshot(path: nil)
      wrap_impl(@impl.screenshot(path: unwrap_impl(path)))
    end

    #
    # Scrolls the widget defined by `selector` in  the specified `direction`.
    def scroll(selector, direction, percent, speed: nil)
      raise NotImplementedError.new('scroll is not implemented yet.')
    end

    #
    # Device serial number.
    def serial
      wrap_impl(@impl.serial)
    end

    #
    # This setting will change the default maximum time for all the methods accepting `timeout` option.
    def set_default_timeout(timeout)
      raise NotImplementedError.new('set_default_timeout is not implemented yet.')
    end
    alias_method :default_timeout=, :set_default_timeout

    #
    # Executes a shell command on the device and returns its output.
    def shell(command)
      wrap_impl(@impl.shell(unwrap_impl(command)))
    end

    #
    # Swipes the widget defined by `selector` in  the specified `direction`.
    def swipe(selector, direction, percent, speed: nil)
      raise NotImplementedError.new('swipe is not implemented yet.')
    end

    #
    # Taps on the widget defined by `selector`.
    def tap_point(selector, duration: nil)
      raise NotImplementedError.new('tap_point is not implemented yet.')
    end

    #
    # Waits for the specific `selector` to either appear or disappear, depending on the `state`.
    def wait(selector, state: nil)
      raise NotImplementedError.new('wait is not implemented yet.')
    end

    #
    # Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy value.
    def wait_for_event(event, optionsOrPredicate: nil)
      raise NotImplementedError.new('wait_for_event is not implemented yet.')
    end

    #
    # This method waits until `AndroidWebView` matching the `selector` is opened and returns it. If there is already an open `AndroidWebView` matching the `selector`, returns immediately.
    def web_view(selector)
      raise NotImplementedError.new('web_view is not implemented yet.')
    end

    #
    # Currently open WebViews.
    def web_views
      raise NotImplementedError.new('web_views is not implemented yet.')
    end

    # @nodoc
    def tap_on(selector, duration: nil, timeout: nil)
      wrap_impl(@impl.tap_on(unwrap_impl(selector), duration: unwrap_impl(duration), timeout: unwrap_impl(timeout)))
    end

    # @nodoc
    def should_close_connection_on_close!
      wrap_impl(@impl.should_close_connection_on_close!)
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
