module Playwright
  define_channel_owner :Playwright do
    def chromium
      @chromium ||= ::Playwright::ChannelOwners::BrowserType.from(@initializer['chromium']).tap do |browser_type|
        browser_type.send(:update_playwright, self)
      end
    end

    def firefox
      @firefox ||= ::Playwright::ChannelOwners::BrowserType.from(@initializer['firefox']).tap do |browser_type|
        browser_type.send(:update_playwright, self)
      end
    end

    def webkit
      @webkit ||= ::Playwright::ChannelOwners::BrowserType.from(@initializer['webkit']).tap do |browser_type|
        browser_type.send(:update_playwright, self)
      end
    end

    def android
      @android ||= ::Playwright::ChannelOwners::Android.from(@initializer['android'])
    end

    def electron
      @electron ||= ::Playwright::ChannelOwners::Electron.from(@initializer['electron'])
    end

    def selectors
      @selectors ||= ::Playwright::SelectorsImpl.new
    end

    def devices
      @connection.local_utils.devices
    end

    # used only from Playwright#connect_to_browser_server
    private def pre_launched_browser
      unless @initializer['preLaunchedBrowser']
        raise 'Malformed endpoint. Did you use launchServer method?'
      end
      ::Playwright::ChannelOwners::Browser.from(@initializer['preLaunchedBrowser'])
    end

    private def pre_connected_android_device
      unless @initializer['preConnectedAndroidDevice']
        raise 'Malformed endpoint. Did you use Android.launchServer method?'
      end
      ::Playwright::ChannelOwners::AndroidDevice.from(@initializer['preConnectedAndroidDevice'])
    end
  end
end
