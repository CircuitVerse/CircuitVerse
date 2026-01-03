---
sidebar_position: 0
---

# Getting started

```
gem 'playwright-ruby-client'
```

Add the line above and then `bundle install`.


Since `playwright-ruby-client` doesn't include Playwright driver nor its downloader, **we have to install Playwright in advance**

```shell
$ npx playwright install
```

and then set `playwright_cli_executable_path: "npx playwright"` into `Playwright.create`.

Other methods of installation is also available. See the detail in [Download Playwright driver](./guides/download_playwright_driver)

## Enjoy with examples

### Capture a site

Navigate pages with `page.goto(url)` and save the screenshot with `page.screenshot(path: './image.png')`.

```rb {6-7}
require 'playwright'

Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
  playwright.chromium.launch(headless: false) do |browser|
    page = browser.new_page
    page.goto('https://github.com/YusukeIwaki')
    page.screenshot(path: './YusukeIwaki.png')
  end
end
```

![image](https://user-images.githubusercontent.com/11763113/104339718-412f9180-553b-11eb-9116-908e1e4b5186.gif)

### Simple scraping

Extract data from a site.

* Grab DOM elements with `page.query_selector(loc)` and `page.query_selector_all(loc)`
* Extract data with `elem.evaluate(js)` or `page.eval_on_selector(js)`
* Wait for navigation with `page.expect_navigation do ... end`

```rb {12-14,17-21}
require 'playwright'

Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
  playwright.chromium.launch(headless: false) do |browser|
    page = browser.new_page
    page.goto('https://github.com/')

    form = page.query_selector("form.js-site-search-form")
    search_input = form.query_selector("input.header-search-input")
    search_input.click
    page.keyboard.type("playwright")
    page.expect_navigation {
      page.keyboard.press("Enter")
    }

    list = page.query_selector("ul.repo-list")
    items = list.query_selector_all("div.f4")
    items.each do |item|
      title = item.eval_on_selector("a", "a => a.innerText")
      puts("==> #{title}")
    end
  end
end
```

```
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

As an experimental feature, we can automate Chrome for Android.

```rb
require 'playwright'

Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
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

![image](https://user-images.githubusercontent.com/11763113/106615177-8467a800-65af-11eb-94d9-c56e71487e78.gif)

### Android native automation

We have to download android-driver for Playwright in advance.

```shell
$ wget https://github.com/microsoft/playwright/raw/master/bin/android-driver-target.apk -O /path/to/playwright-driver/package/bin/android-driver-target.apk
$ wget https://github.com/microsoft/playwright/raw/master/bin/android-driver.apk -O /path/to/playwright-driver/package/bin/android-driver.apk
```

(If you downloaded Playwright via npm, replace /path/to/playwright-driver/package/ with ./node_modules/playwright/ above.)

```rb
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
