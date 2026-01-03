module Playwright
  #
  # Playwright has **experimental** support for Android automation. This includes Chrome for Android and Android WebView.
  #
  # *Requirements*
  # - Android device or AVD Emulator.
  # - [ADB daemon](https://developer.android.com/studio/command-line/adb) running and authenticated with your device. Typically running `adb devices` is all you need to do.
  # - [`Chrome 87`](https://play.google.com/store/apps/details?id=com.android.chrome) or newer installed on the device
  # - "Enable command line on non-rooted devices" enabled in `chrome://flags`.
  #
  # *Known limitations*
  # - Raw USB operation is not yet supported, so you need ADB.
  # - Device needs to be awake to produce screenshots. Enabling "Stay awake" developer mode will help.
  # - We didn't run all the tests against the device, so not everything works.
  #
  # *How to run*
  #
  # An example of the Android automation script would be:
  class Android < PlaywrightApi

    #
    # This methods attaches Playwright to an existing Android device.
    # Use [`method: Android.launchServer`] to launch a new Android server instance.
    def connect(wsEndpoint, headers: nil, slowMo: nil, timeout: nil)
      raise NotImplementedError.new('connect is not implemented yet.')
    end

    #
    # Returns the list of detected Android devices.
    def devices(host: nil, omitDriverInstall: nil, port: nil)
      wrap_impl(@impl.devices(host: unwrap_impl(host), omitDriverInstall: unwrap_impl(omitDriverInstall), port: unwrap_impl(port)))
    end

    #
    # This setting will change the default maximum time for all the methods accepting `timeout` option.
    def set_default_timeout(timeout)
      wrap_impl(@impl.set_default_timeout(unwrap_impl(timeout)))
    end
    alias_method :default_timeout=, :set_default_timeout

    # @nodoc
    def set_default_navigation_timeout(timeout)
      wrap_impl(@impl.set_default_navigation_timeout(unwrap_impl(timeout)))
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
