---
sidebar_position: 21
---

# Reuse Cookie and LocalStorage

In most cases, authentication state is stored in cookie or local storage. When we just want to keep authenticated, it is a good solution to dump/load 'storage state' (= Cookie + LocalStorage).
https://playwright.dev/docs/next/auth#reuse-authentication-state

* Dump storage state using [BrowserContext#storage_state](/docs/api/browser_context#storage_state) with `path: /path/to/state.json`
* Load storage state by specifying the parameter `storageState: /path/to/state.json` into [Browser#new_context](/docs/api/browser#new_context) or [Browser#new_page](/docs/api/browser#new_page)

## Example

Generally in browser automation, it is very difficult to bypass 2FA or reCAPTCHA in login screen. In such cases, we would consider

* Authenticate manually by hand
* Resume automation with the authentication result


```ruby {16,21}
require 'playwright'
require 'pry'

force_login = !File.exist?('github_state.json')

Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
  if force_login
    # Use headful mode for manual operation.
    playwright.chromium.launch(headless: false, channel: 'chrome') do |browser|
      page = browser.new_page
      page.goto('https://github.com/login')

      # Login manually.
      binding.pry

      page.context.storage_state(path: 'github_state.json')
    end
  end

  playwright.chromium.launch do |browser|
    page = browser.new_page(storageState: 'github_state.json')
    page.goto('https://github.com/notifications')
    page.screenshot(path: 'github_notification.png')
  end
end
```

When we execute this script at the first time (without github_state.json), login screen is shown:

![login screen is shown](https://user-images.githubusercontent.com/11763113/129394130-7a248f6a-56f0-40b0-a4dd-f0f65d71b3a9.png)

and input credentials manually:

![input credentials manually](https://user-images.githubusercontent.com/11763113/129394155-fccc280e-5e6b-46c7-8a4d-a99d7db02c7f.png)

and hit `exit` in Pry console.

```

     9:
    10:     # Login manually. Hit `exit` in Pry console after authenticated.
    11:     require 'pry'
    12:     binding.pry
    13:
 => 14:     page.context.storage_state(path: 'github_state.json')
    15:   end if force_login
    16:
    17:   playwright.chromium.launch do |browser|
    18:     page = browser.new_page(storageState: 'github_state.json')
    19:     page.goto('https://github.com/notifications')

[1] pry(main)> exit
```

then we can enjoy automation with keeping authenticated. Login screen is never shown until github_state.json is deleted :)

![github_notification.png](https://user-images.githubusercontent.com/11763113/129394879-838797eb-135f-41ab-b965-8d6fabde6109.png)
