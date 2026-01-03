---
sidebar_position: 2
---

# Launch Browser

![image](https://user-images.githubusercontent.com/11763113/118982444-68e5a900-b9b6-11eb-92a8-3e8fcbe36186.png)

## Create Playwright session

In oder to launch browser, it is required to create Playwright session.

In previous examples,

```rb
Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
  # Play with `playwright` here
end
```

this is the exact procedure for creating Playwright session. Choose either of method for creating the session.

### Define scoped Playwright session with block

```rb
Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
  # Play with `playwright` here
end
```

As is described repetedly, this is the recommended way for creating Playwright session. Even when any exception happens, Playwright session is safely ended on leaving the block.

Internally `playwright run-driver` session is alive during the block.

### Define start/end of the Playwright session separately without block.

Sometimes we have to define separated start/end definition. `playwright-ruby-client` also allows it.

```rb
class SomeClass

  def start_playwright
    # Start Playwright driver (runs `playwright run-driver` internally)
    @playwright_exec = Playwright.create(playwright_cli_executable_path: 'npx playwright')
  end

  def stop_playwright!
    # Stop Playwright driver
    @playwright_exec.stop
  end

  def play_with_playwright(&blk)
    # Acquire Playwright instance with PlaywrightExecution#playwright
    playwright = @playwright_exec.playwright

    browser = playwright.chromium.launch

    begin
      blk.call(browser)
    ensure
      browser.close
    end
  end
end
```

Note that we have to make sure to call `PlaywrightExecution#stop` (`stop_playwright!` in this case).

## Create browser instance

Playwright allows launching several browsers.

* `playwright.chromium.launch` for launching Chrome, Microsoft Edge, Chromium
* `playwright.firefox.launch` for launching (modified version of) Firefox
* `playwright.webkit.launch` for launching (modified version of) WebKit/Safari

It is recommended in most cases to launch browser with block, which automatically closes the launched browser on end.

```rb
# scoped browser block
playwright.chromium.launch do |browser|
  # Play with `browser`
end
```

Of course, you can manually call `Browser#close` when the browser is launched without block.

```rb
# separated start/end
browser = playwright.chromium.launch

begin
  # Play with `@browser`
ensure
  browser.close
end
```

## Open new window and new tab

Use `Browser#new_context` to prepare a new browser window and use `BrowserContext#new_page` to create a new tab.
Also we can use `Browser#new_page` to create a new window and new tab at once.

```rb
Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
  playwright.chromium.launch(headless: false) do |browser| # Chromium task icon appers in.
    context = browser.new_context # Prepare new window.
    page = context.new_page # Open new window and new tab here. (about:blank)
    page.goto('https://example.com') # Navigate to a site.

    page2 = context.new_page # Open another tab here.
    page2.goto('https://example.com') # Navigate to a site.

    another_context = browser.new_context # Prepare another window here.
    another_page = another_context.new_page # Open a new window and new tab.
    another_page.goto('https://example.com/') # Navigate to a site.
  end
end
```

Note that each browser context is isolated and not persisted by default. When persistent browser context is needed, we can use [BrowserType#launch_persistent_context](/docs/api/browser_type#launch_persistent_context).
