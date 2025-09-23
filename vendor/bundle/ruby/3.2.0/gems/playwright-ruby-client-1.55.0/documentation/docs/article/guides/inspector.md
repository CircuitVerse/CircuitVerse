---
sidebar_position: 30
---

# Playwright inspector

Playwright provides an useful inspector.
https://playwright.dev/docs/inspector/

## Overview

```ruby {4,8}
playwright.chromium.launch(headless: false) do |browser|
  browser.new_context do |context|
    # This method call should be put just after creating BrowserContext.
    context.enable_debug_console!

    page = context.new_page
    page.goto('http://example.com/')
    page.pause
  end
end
```

`page.pause` requires Playwright debug session, and it can be enabled by calling `BrowserContext#enable_debug_console!` in advance.

Note that since Ruby is not officially supported in Playwright, many limitations exist. We CANNOT

* Launch inspector via `PWDEBUG=1`
* Debug without inspector UI (`PWDEBUG=console` is not working well)
* Show Ruby code in inspector
