[![Gem Version](https://badge.fury.io/rb/playwright-ruby-client.svg)](https://badge.fury.io/rb/playwright-ruby-client)

# 🎭 Playwright client for Ruby

#### [Docs](https://playwright-ruby-client.vercel.app/docs/article/getting_started) | [API](https://playwright-ruby-client.vercel.app/docs/api/playwright)

## Getting Started

```
gem 'playwright-ruby-client'
```

and then 'bundle install'.

Since playwright-ruby-client doesn't include the playwright driver, **we have to install [playwright](https://github.com/microsoft/playwright) in advance**.

```
npm install playwright
./node_modules/.bin/playwright install
```

And set `playwright_cli_executable_path: './node_modules/.bin/playwright'`

**Prefer playwrighting without Node.js?**

Instead of npm, you can also directly download playwright driver from playwright.azureedge.net/builds/. The URL can be easily detected from [here](https://github.com/microsoft/playwright-python/blob/cb5409934629adaabc0cff1891080de2052fa778/setup.py#L73-L77)

### Capture a site

```ruby
require 'playwright'

Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright') do |playwright|
  playwright.chromium.launch(headless: false) do |browser|
    page = browser.new_page
    page.goto('https://github.com/YusukeIwaki')
    page.screenshot(path: './YusukeIwaki.png')
  end
end
```

![image](https://user-images.githubusercontent.com/11763113/104339718-412f9180-553b-11eb-9116-908e1e4b5186.gif)

### Simple scraping

```ruby
require 'playwright'

Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright') do |playwright|
  playwright.chromium.launch(headless: false) do |browser|
    page = browser.new_page
    page.goto('https://github.com/')

    page.get_by_placeholder("Search or jump to...").click
    page.locator('input[name="query-builder-test"]').click

    expect(page.keyboard).to be_a(::Playwright::Keyboard)

    page.keyboard.type("playwright")
    page.expect_navigation {
      page.keyboard.press("Enter")
    }

    list = page.get_by_test_id('results-list').locator('.search-title')

    # wait for item to appear
    list.first.wait_for

    # list them
    list.locator('.search-title').all.each do |item|
      title = item.text_content
      puts("==> #{title}")
    end
  end
end
```

```sh
$ bundle exec ruby main.rb
==> microsoft/playwright
==> microsoft/playwright-python
==> microsoft/playwright-cli
==> checkly/headless-recorder
==> microsoft/playwright-sharp
==> playwright-community/jest-playwright
==> microsoft/playwright-test
==> mxschmitt/playwright-go
==> microsoft/playwright-java
==> MarketSquare/robotframework-browser
```

### Android browser automation

```ruby
require 'playwright'

Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright') do |playwright|
  devices = playwright.android.devices
  unless devices.empty?
    device = devices.last
    begin
      puts "Model: #{device.model}"
      puts "Serial: #{device.serial}"
      puts device.shell('ls /system')

      device.launch_browser do |context|
        page = context.pages.first
        page.goto('https://github.com/YusukeIwaki')
        page.click('header button')
        page.click('input[name="q"]')
        page.keyboard.type('puppeteer')
        page.expect_navigation {
          page.keyboard.press('Enter')
        }
        page.screenshot(path: 'YusukeIwaki.android.png')
      end
    ensure
      device.close
    end
  end
end
```

![android-browser](https://user-images.githubusercontent.com/11763113/106615177-8467a800-65af-11eb-94d9-c56e71487e78.gif)

### Android native automation

We have to download android-driver for Playwright in advance.

```
wget https://github.com/microsoft/playwright/raw/master/bin/android-driver-target.apk -O /path/to/playwright-driver/package/bin/android-driver-target.apk
wget https://github.com/microsoft/playwright/raw/master/bin/android-driver.apk -O /path/to/playwright-driver/package/bin/android-driver.apk
```

(If you downloaded Playwright via npm, replace `/path/to/playwright-driver/package/` with `./node_modules/playwright/` above.)

```ruby
require 'playwright'

Playwright.create(playwright_cli_executable_path: ENV['PLAYWRIGHT_CLI_EXECUTABLE_PATH']) do |playwright|
  devices = playwright.android.devices
  unless devices.empty?
    device = devices.last
    begin
      device.shell('input keyevent POWER')
      device.shell('input keyevent POWER')
      device.shell('input keyevent 82')
      sleep 1
      device.shell('cmd statusbar expand-notifications')

      # pp device.tree
      # pp device.info(res: 'com.android.systemui:id/clock')
      device.tap_on(res: 'com.android.systemui:id/clock')
    ensure
      device.close
    end
  end
end

```

### Communicate with Playwright server

If your environment doesn't accept installing browser or creating browser process, consider separating Ruby client and Playwright server.

![structure](https://user-images.githubusercontent.com/11763113/124934448-ad4d0700-e03f-11eb-942e-b9f3282bb703.png)

For launching Playwright server, just execute:

```
npx playwright install && npx playwright run-server --port 8080 --path /ws
```

and we can connect to the server with the code like this:

```ruby
Playwright.connect_to_playwright_server('ws://127.0.0.1:8080/ws?browser=chromium') do |playwright|
  playwright.chromium.launch do |browser|
    page = browser.new_page
    page.goto('https://github.com/YusukeIwaki')
    page.screenshot(path: './YusukeIwaki.png')
  end
end
```

When `Playwright.connect_to_playwright_server` is used, playwright_cli_executable_path is not required.

For more detailed instraction, refer this article: https://playwright-ruby-client.vercel.app/docs/article/guides/playwright_on_alpine_linux

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Playwright project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/playwright-ruby-client/blob/master/CODE_OF_CONDUCT.md).
