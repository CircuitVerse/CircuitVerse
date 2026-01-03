---
sidebar_position: 3
---

# Capybara driver for Ruby on Rails application

`playwright-ruby-client` is a client library just for browser automation, while Rails uses [Capybara](https://github.com/teamcapybara/capybara) for system testing.

`capybara-playwright-driver` provides a [Capybara](https://github.com/teamcapybara/capybara) driver based on playwright-ruby-client and makes it easy to integrate into Ruby on Rails applications.

## Installation

Add the line below into Gemfile:

```rb
gem 'capybara-playwright-driver'
```

and then `bundle install`.

Note that capybara-playwright-driver does not depend on Selenium. But `selenium-webdriver` is also required [on Rails 5.x, 6.0](https://github.com/rails/rails/pull/39179)

## Register and configure Capybara driver

```rb
Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(app,
    browser_type: :chromium, # :chromium (default) or :firefox, :webkit
    headless: false, # true for headless mode (default), false for headful mode.
  )
end
```

### Update timeout

Capybara sets the default value of timeout to _2 seconds_. Generally it is too short to wait for HTTP responses.

It is recommended to set the timeout to 15-30 seconds for Playwright driver.

```rb
Capybara.default_max_wait_time = 15
```

### (Optional) Update default driver

By default, Capybara driver is set to `:rack_test`, which works only with non-JS contents. If your Rails application has many JavaScript contents, it is recommended to change the default driver to `:playwright`.

```rb
Capybara.default_driver = :playwright
Capybara.javascript_driver = :playwright
```

It is not mandatry. Without changing the default driver, you can still use Playwright driver by specifying `Capybara.current_driver = :playwright` (or `driven_by :playwright` in system spec) explicitly.

### (reference) Available driver options

These parameters can be passed into `Capybara::Playwright::Driver.new`

- `playwright_cli_executable_path`
  - Refer [this article](./download_playwright_driver) to understand what to specify.
- `browser_type`
  - `:chromium` (default), `:firefox`, or `:webkit`
- Parameters for [Playwright::BrowserType#launch](/docs/api/browser_type#launch)
  - args
  - channel
    - `chrome`, `msedge`, `chrome-beta`, `chrome-dev`, `chrome-canary`, `msedge-beta`, `msedge-dev` Browser distribution channel. Read more about using [Google Chrome & Microsoft Edge](https://playwright.dev/docs/browsers#google-chrome--microsoft-edge)
  - devtools
  - downloadsPath
  - env
  - executablePath
  - firefoxUserPrefs
  - headless
  - ignoreDefaultArgs
  - proxy
  - slowMo
  - timeout
- Parameters for [Playwright::Browser#new_context](/docs/api/browser#new_context)
  - bypassCSP
  - colorScheme
  - deviceScaleFactor
  - extraHTTPHeaders
  - geolocation
  - hasTouch
  - httpCredentials
  - ignoreHTTPSErrors
  - isMobile
  - javaScriptEnabled
  - locale
  - noViewport
  - offline
  - permissions
  - proxy
  - record_har_omit_content
  - record_har_path
  - record_video_dir
  - record_video_size
  - screen
  - serviceWorkers
  - storageState
  - timezoneId
  - userAgent
  - viewport

```ruby
driver_opts = {
  # `playwright` command path.
  playwright_cli_executable_path: './node_modules/.bin/playwright',

  # Use firefox for testing.
  browser_type: :firefox,

  # Headful mode.
  headless: false,

  # Slower operation
  slowMo: 50, # integer. (50-100 would be good for most cases)
}

Capybara::Playwright::Driver.new(app, driver_opts)
```

## Available functions and Limitations

### Capybara DSL

Most of the methods of `Capybara::Session` and `Capybara::Node::Element` are available. However the following method is not yet implemented.

- `Capybara::Node::Element#drop`

### Playwright-native scripting

We can also describe Playwright-native automation script using `with_playwright_page` and `with_playwright_element_handle`.

```ruby
# With Capybara DSL
find('a[data-item-type="global_search"]').click

# With Playwright-native Page
Capybara.current_session.driver.with_playwright_page do |page|
  # `page` is an instance of Playwright::Page.
  page.click('a[data-item-type="global_search"]')
end
```

```ruby
all('.list-item').each do |li|
  # With Capybara::Node::Element method
  puts li.all('a').first.text

  # With Playwright-native ElementHandle
  puts li.with_playwright_element_handle do |handle|
    # `handle` is an instance of Playwright::ElementHandle
    handle.query_selector('a').text_content
  end
end
```

Generally, Capybara DSL seems simple, but Playwright-native scripting are more precise and efficient. Also `waitForNavigation`, `waitForSelector`, and many other Playwright functions are available with Playwright-native scripting.

### Screen recording

NO NEED to keep sitting in front of screen during test. Just record what happened with video.

For example, we can store the video for [Allure report](https://github.com/allure-framework/allure-ruby) as below:

```ruby
before do |example|
  Capybara.current_session.driver.on_save_screenrecord do |video_path|
    Allure.add_attachment(
      name: "screenrecord - #{example.description}",
      source: File.read(video_path),
      type: Allure::ContentType::WEBM,
      test_case: true,
    )
  end
end
```

![sceenrecord](https://user-images.githubusercontent.com/11763113/121126629-71b5f600-c863-11eb-8f88-7924ab669946.gif)

For more details, refer [Recording video](./recording_video.md#using-screen-recording-from-capybara-driver)

### Screenshot just before teardown

In addition to `Capybara::Session#save_screenshot`, capybara-playwright-driver have another method for storing last screen state just before teardown.

For example, we can attach the screenshot for [Allure report](https://github.com/allure-framework/allure-ruby) as below:

```ruby
before do |example|
  Capybara.current_session.driver.on_save_raw_screenshot_before_reset do |raw_screenshot|
    Allure.add_attachment(
      name: "screenshot - #{example.description}",
      source: raw_screenshot,
      type: Allure::ContentType::PNG,
      test_case: true,
    )
  end
end
```

### Tracing for postmortem

Playwright users often expect to see what happened in the browser when the test failed. `capybara-playwright-driver` provides a feature to store the trace easily.

```ruby
before do |example|
  Capybara.current_session.driver.on_save_trace do |trace_zip_path|
    Allure.add_attachment(
      name: "trace - #{example.description}",
      source: File.read(trace_zip_path),
      type: 'application/zip',
      test_case: true,
    )
  end
end
```

This example code would attach the trace zip file to Allure report for each test case.

![add trace image](https://user-images.githubusercontent.com/11763113/282307106-520d800b-67ac-4e14-98bb-75a8bbb98a1f.png)

We can download and show the trace with `playwright show-trace` command.

```
npx playwright show-trace ababcdcdefef.zip
```

![show-trace image](https://user-images.githubusercontent.com/11763113/282307098-a4167c32-d5e7-4631-a3b6-62d278efbeef.png)

Instead of the easy configuration using `on_save_trace`, we can also use `page.driver.start_tracing` / `page.driver.stop_tracing` or `page.driver.with_trace do { ... }` for storing the trace with detailed options. See [the PR](https://github.com/YusukeIwaki/capybara-playwright-driver/pull/66) for more details including example codes for RSpec.

### Limitations

- Playwright doesn't allow clicking invisible DOM elements or moving elements. `click` sometimes doesn't work as Selenium does. See the detail in https://playwright.dev/docs/actionability/
- `current_window.maximize` and `current_window.fullscreen` work only on headful (non-headless) mode, as selenium driver does.
- `Capybara::Node::Element#drag_to` does not accept `html5` parameter. HTML5 drag and drop is not fully supported in Playwright.
