---
sidebar_position: 10
---

# BrowserType


BrowserType provides methods to launch a specific browser instance or connect to an existing one. The following is a
typical example of using Playwright to drive automation:

```ruby
chromium = playwright.chromium
chromium.launch do |browser|
  page = browser.new_page
  page.goto('https://example.com/')

  # other actions

end
```

## connect_over_cdp

```
def connect_over_cdp(
      endpointURL,
      headers: nil,
      slowMo: nil,
      timeout: nil,
      &block)
```


This method attaches Playwright to an existing browser instance using the Chrome DevTools Protocol.

The default browser context is accessible via [Browser#contexts](./browser#contexts).

**NOTE**: Connecting over the Chrome DevTools Protocol is only supported for Chromium-based browsers.

**NOTE**: This connection is significantly lower fidelity than the Playwright protocol connection via [BrowserType#connect](./browser_type#connect). If you are experiencing issues or attempting to use advanced functionality, you probably want to use [BrowserType#connect](./browser_type#connect).

**Usage**

```ruby
browser = playwright.chromium.connect_over_cdp("http://localhost:9222")
default_context = browser.contexts.first
page = default_context.pages.first
```

## executable_path

```
def executable_path
```


A path where Playwright expects to find a bundled browser executable.

## launch

```
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
```


Returns the browser instance.

**Usage**

You can use `ignoreDefaultArgs` to filter out `--mute-audio` from default arguments:

```ruby
browser = playwright.chromium.launch( # or "firefox" or "webkit".
  ignoreDefaultArgs: ["--mute-audio"]
)

browser.close
```

> **Chromium-only** Playwright can also be used to control the Google Chrome or Microsoft Edge browsers, but it works best with the version of
Chromium it is bundled with. There is no guarantee it will work with any other version. Use `executablePath`
option with extreme caution.

>

> If Google Chrome (rather than Chromium) is preferred, a
[Chrome Canary](https://www.google.com/chrome/browser/canary.html) or
[Dev Channel](https://www.chromium.org/getting-involved/dev-channel) build is suggested.

>

> Stock browsers like Google Chrome and Microsoft Edge are suitable for tests that require proprietary media codecs for video playback. See [this article](https://www.howtogeek.com/202825/what%E2%80%99s-the-difference-between-chromium-and-chrome/) for other differences between Chromium and Chrome.
[This article](https://chromium.googlesource.com/chromium/src/+/lkgr/docs/chromium_browser_vs_google_chrome.md)
describes some differences for Linux users.

## launch_persistent_context

```
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
```


Returns the persistent browser context instance.

Launches browser that uses persistent storage located at `userDataDir` and returns the only context. Closing
this context will automatically close the browser.

## name

```
def name
```


Returns browser name. For example: `'chromium'`, `'webkit'` or `'firefox'`.
