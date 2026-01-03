---
sidebar_position: 20
---

# Semi-automation

Playwright Browser context is isolated and not persisted by default. But we can also use persistent browser context using [BrowserType#launch_persistent_context](/docs/api/browser_type#launch_persistent_context).
This allow us to intermediate into automation, for example

* Authenticate with OAuth2 manually before automation
* Testing a page after some chrome extensions are installed manually

Keep in mind repeatedly that persistent browser context is NOT RECOMMENDED for most cases because it would bring many side effects. Consider [reusing cookie and local storage](./use_storage_state) when you just want to keep authenticated across browser contexts.

## Pause automation for manual operation

We can simply use `binding.pry`  (with `pry-byebug` installed).

```ruby {4}
playwright.chromium.launch_persistent_context('./data/', headless: false) do |context|
  page = context.new_page
  page.goto('https://example.com/')
  binding.pry
end
```

When script is executed, it is paused as below.

```
    3:
    4: playwright.chromium.launch_persistent_context('./data/', headless: false) do |context|
    5:   page = context.new_page
    6:   page.goto('https://example.com/')
 => 7:   binding.pry
    8: end

[1] pry(main)>
```

We can inspect using `page`, `context` and also we can operate something manually during the pause.

See https://github.com/deivid-rodriguez/pry-byebug for more detailed debugging options.

## Working with Chrome extensions

**Playwright disables the Chrome extension feature by default.**
We have to enable it for installing Chrome extension, by passing these 3 parameters on launch.

* `acceptDownloads: true`
* `headless: false`
* `ignoreDefaultArgs: ['--disable-extensions']`

```ruby
require 'playwright'
require 'pry'

Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright') do |playwright|
  launch_params = {
    acceptDownloads: true,
    channel: 'chrome',
    headless: false,
    ignoreDefaultArgs: ['--disable-extensions'],
  }

  playwright.chromium.launch_persistent_context('./data/', **launch_params) do |context|
    page = context.new_page
    page.goto('https://example.com/')
    binding.pry
  end
end
```
