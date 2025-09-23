module Playwright
  module Events
  end
end

# @see https://github.com/microsoft/playwright/blob/master/src/client/events.ts
{
  AndroidDevice: {
    WebView: 'webview',
    Close: 'close'
  },

  AndroidSocket: {
    Data: 'data',
    Close: 'close'
  },

  AndroidWebView: {
    Close: 'close'
  },

  Browser: {
    Disconnected: 'disconnected'
  },

  BrowserContext: {
    BackgroundPage: 'backgroundpage',
    Close: 'close',
    Console: 'console',
    Dialog: 'dialog',
    Page: 'page',
    WebError: 'weberror',
    ServiceWorker: 'serviceworker',
    Request: 'request',
    Response: 'response',
    RequestFailed: 'requestfailed',
    RequestFinished: 'requestfinished',
  },

  BrowserServer: {
    Close: 'close',
  },

  Page: {
    Close: 'close',
    Crash: 'crash',
    Console: 'console',
    Dialog: 'dialog',
    Download: 'download',
    FileChooser: 'filechooser',
    DOMContentLoaded: 'domcontentloaded',
    # Can't use just 'error' due to node.js special treatment of error events.
    # @see https://nodejs.org/api/events.html#events_error_events
    PageError: 'pageerror',
    Request: 'request',
    Response: 'response',
    RequestFailed: 'requestfailed',
    RequestFinished: 'requestfinished',
    FrameAttached: 'frameattached',
    FrameDetached: 'framedetached',
    FrameNavigated: 'framenavigated',
    Load: 'load',
    Popup: 'popup',
    WebSocket: 'websocket',
    Worker: 'worker',
  },

  WebSocket: {
    Close: 'close',
    Error: 'socketerror',
    FrameReceived: 'framereceived',
    FrameSent: 'framesent',
  },

  Worker: {
    Close: 'close',
  },

  ElectronApplication: {
    Close: 'close',
    Window: 'window',
  },
}.each do |key, events|
  events_module = Module.new
  events.each do |event_key, event_value|
    events_module.const_set(event_key, event_value)
  end
  events_module.define_singleton_method(:keys) { events.keys }
  ::Playwright::Events.const_set(key, events_module)
end
