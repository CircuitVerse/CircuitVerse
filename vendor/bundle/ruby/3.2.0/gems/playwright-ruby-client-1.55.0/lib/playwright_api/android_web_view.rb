module Playwright
  #
  # `AndroidWebView` represents a WebView open on the `AndroidDevice`. WebView is usually obtained using [`method: AndroidDevice.webView`].
  class AndroidWebView < PlaywrightApi

    #
    # Connects to the WebView and returns a regular Playwright `Page` to interact with.
    def page
      raise NotImplementedError.new('page is not implemented yet.')
    end

    #
    # WebView process PID.
    def pid
      raise NotImplementedError.new('pid is not implemented yet.')
    end

    #
    # WebView package identifier.
    def pkg
      raise NotImplementedError.new('pkg is not implemented yet.')
    end
  end
end
