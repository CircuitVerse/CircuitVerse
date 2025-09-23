---
sidebar_position: 10
---

# Browser


A Browser is created via [BrowserType#launch](./browser_type#launch). An example of using a [Browser](./browser) to create a [Page](./page):

```ruby
firefox = playwright.firefox
browser = firefox.launch
begin
  page = browser.new_page
  page.goto("https://example.com")
ensure
  browser.close
end
```

## browser_type

```
def browser_type
```


Get the browser type (chromium, firefox or webkit) that the browser belongs to.

## close

```
def close(reason: nil)
```


In case this browser is obtained using [BrowserType#launch](./browser_type#launch), closes the browser and all of its pages (if any
were opened).

In case this browser is connected to, clears all created contexts belonging to this browser and disconnects from the
browser server.

**NOTE**: This is similar to force-quitting the browser. To close pages gracefully and ensure you receive page close events, call [BrowserContext#close](./browser_context#close) on any [BrowserContext](./browser_context) instances you explicitly created earlier using [Browser#new_context](./browser#new_context) **before** calling [Browser#close](./browser#close).

The [Browser](./browser) object itself is considered to be disposed and cannot be used anymore.

## contexts

```
def contexts
```


Returns an array of all open browser contexts. In a newly created browser, this will return zero browser contexts.

**Usage**

```ruby
playwright.webkit.launch do |browser|
  puts browser.contexts.count # => 0
  context = browser.new_context
  puts browser.contexts.count # => 1
end
```

## connected?

```
def connected?
```


Indicates that the browser is connected.

## new_browser_cdp_session

```
def new_browser_cdp_session
```


**NOTE**: CDP Sessions are only supported on Chromium-based browsers.

Returns the newly created browser session.

## new_context

```
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
```


Creates a new browser context. It won't share cookies/cache with other browser contexts.

**NOTE**: If directly using this method to create [BrowserContext](./browser_context)s, it is best practice to explicitly close the returned context via [BrowserContext#close](./browser_context#close) when your code is done with the [BrowserContext](./browser_context),
and before calling [Browser#close](./browser#close). This will ensure the `context` is closed gracefully and any artifacts—like HARs and videos—are fully flushed and saved.

**Usage**

```ruby
playwright.firefox.launch do |browser| # or "chromium.launch" or "webkit.launch".
  # create a new incognito browser context.
  browser.new_context do |context|
    # create a new page in a pristine context.
    page = context.new_page
    page.goto("https://example.com")
  end
end
```

## new_page

```
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
```


Creates a new page in a new browser context. Closing this page will close the context as well.

This is a convenience API that should only be used for the single-page scenarios and short snippets. Production code and
testing frameworks should explicitly create [Browser#new_context](./browser#new_context) followed by the
[BrowserContext#new_page](./browser_context#new_page) to control their exact life times.

## start_tracing

```
def start_tracing(page: nil, categories: nil, path: nil, screenshots: nil)
```


**NOTE**: This API controls [Chromium Tracing](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool) which is a low-level chromium-specific debugging tool. API to control [Playwright Tracing](https://playwright.dev/python/docs/trace-viewer) could be found [here](./tracing).

You can use [Browser#start_tracing](./browser#start_tracing) and [Browser#stop_tracing](./browser#stop_tracing) to create a trace file that can
be opened in Chrome DevTools performance panel.

**Usage**

```ruby
browser.start_tracing(page: page, path: "trace.json")
begin
  page.goto("https://www.google.com")
ensure
  browser.stop_tracing
end
```

## stop_tracing

```
def stop_tracing
```


**NOTE**: This API controls [Chromium Tracing](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool) which is a low-level chromium-specific debugging tool. API to control [Playwright Tracing](https://playwright.dev/python/docs/trace-viewer) could be found [here](./tracing).

Returns the buffer with trace data.

## version

```
def version
```


Returns the browser version.
