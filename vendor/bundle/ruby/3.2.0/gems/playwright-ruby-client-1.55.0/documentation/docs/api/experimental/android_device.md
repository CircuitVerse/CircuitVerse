---
sidebar_position: 10
---

# AndroidDevice


[AndroidDevice](./android_device) represents a connected device, either real hardware or emulated. Devices can be obtained using [Android#devices](./android#devices).

## close

```
def close
```


Disconnects from the device.

## info

```
def info(selector)
```


Returns information about a widget defined by `selector`.

## launch_browser

```
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
```


Launches Chrome browser on the device, and returns its persistent context.

## model

```
def model
```


Device model.

## screenshot

```
def screenshot(path: nil)
```


Returns the buffer with the captured screenshot of the device.

## serial

```
def serial
```


Device serial number.

## shell

```
def shell(command)
```


Executes a shell command on the device and returns its output.

## input
