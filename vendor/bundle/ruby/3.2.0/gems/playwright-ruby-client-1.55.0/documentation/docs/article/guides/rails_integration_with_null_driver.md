---
sidebar_position: 4
---

# Use Capybara without DSL

:::note

This article shows advanced-level configuration of Capybara and RSpec for more accurate automation/testing.
If you want to just integrate Playwright into Rails application, refer the basic [configuration guide](./rails_integration)
:::

## Background

[capybara-playwright-driver](./rails_integration) is easy to configure and migrate from Selenium or another Capybara driver, however it is a little **inaccurate** and would sometimes cause 'flaky test' problem originated from the internal implementation of Capybara DSL.

Also **we cannot use most of useful Playwright features in Capybara driver**, such as auto-waiting, various kind of selectors, and some users would want to use Playwright features as it is without Capybara DSL.

This article shows how to use playwright-ruby-client without Capybara DSL in Rails and RSpec.

## Configure Capybara driver just for launching Rails server

Capybara prepares the test server only when the configured driver returns true on `needs_server?` method. So we have to implement minimum driver like this:

```ruby {5-7} title=spec/support/capybara_null_driver.rb
RSpec.configure do |config|
  require 'capybara'

  class CapybaraNullDriver < Capybara::Driver::Base
    def needs_server?
      true
    end
  end

  Capybara.register_driver(:null) { CapybaraNullDriver.new }

  ...
end
```

## Launch browser on each test

Now Capybara DSL is unavailable with CapybaraNullDriver, we have to manually launch browsers using playwright-ruby-client.

```rb
RSpec.configure do |config|
  require 'capybara'

  ...

  require 'playwright'

  config.around(driver: :null) do |example|
    Capybara.current_driver = :null

    # Rails server is launched here, at the first time of accessing Capybara.current_session.server
    base_url = Capybara.current_session.server.base_url

    Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright') do |playwright|
      # pass any option for Playwright#launch and Browser#new_page as you prefer.
      playwright.chromium.launch(headless: false) do |browser|
        @playwright_page = browser.new_page(baseURL: base_url)
        example.run
      end
    end
  end
end
```

With the configuration above, we can describe system-test codes with native Playwright methods like below:

```rb
require 'rails_helper'

describe 'example', driver: :null do
  let!(:user) { FactoryBot.create(:user) }
  let(:page) { @playwright_page }

  it 'can browse' do
    page.goto("/tests/#{user.id}")
    page.wait_for_selector('input').type('hoge')
    page.keyboard.press('Enter')
    expect(page.text_content('#content')).to include('hoge')
  end
end
```

## Minitest Usage

We can do something similar with the default Rails setup using Minitest. Here's the same example written with Minitest:

```rb
# test/application_system_test_case.rb

require 'playwright'

class CapybaraNullDriver < Capybara::Driver::Base
  def needs_server?
    true
  end
end

Capybara.register_driver(:null) { CapybaraNullDriver.new }

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :null

  def self.playwright
    @playwright ||= Playwright.create(playwright_cli_executable_path: Rails.root.join("node_modules/.bin/playwright"))
  end
  
  def before_setup
    super    
    base_url = Capybara.current_session.server.base_url
    @playwright_browser = self.class.playwright.playwright.chromium.launch(headless: false)
    @playwright_page = @playwright_browser.new_page(baseURL: base_url)
  end

  def after_teardown
    super
    @browser.close
  end
end
```

And here is the same test:

```rb
require "application_system_test_case"

class ExampleTest < ApplicationSystemTestCase
  def setup
    @user = User.create!
    @page = @playwright_page
  end

  test 'can browse' do
    @page.goto("/tests/#{user.id}")
    @page.wait_for_selector('input').type('hoge')
    @page.keyboard.press('Enter')
    
    assert @page.text_content('#content').include?('hoge')
  end
end
```
