---
sidebar_position: 10
---

# Playwright


Playwright module provides a method to launch a browser instance. The following is a typical example of using Playwright
to drive automation:

```ruby
require 'playwright'

Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
  chromium = playwright.chromium # or "firefox" or "webkit".
  chromium.launch do |browser|
    page = browser.new_page
    page.goto('https://example.com/')

    # other actions

  end
end
```

## chromium


This object can be used to launch or connect to Chromium, returning instances of [Browser](./browser).

## devices


Returns a dictionary of devices to be used with [Browser#new_context](./browser#new_context) or [Browser#new_page](./browser#new_page).

```ruby
require 'playwright'

Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
  iphone = playwright.devices["iPhone 6"]
  playwright.webkit.launch do |browser|
    context = browser.new_context(**iphone)
    page = context.new_page
    page.goto('https://example.com/')

    # other actions

  end
end
```

## firefox


This object can be used to launch or connect to Firefox, returning instances of [Browser](./browser).

## selectors


Selectors can be used to install custom selector engines. See
[extensibility](https://playwright.dev/python/docs/extensibility) for more information.

## webkit


This object can be used to launch or connect to WebKit, returning instances of [Browser](./browser).
