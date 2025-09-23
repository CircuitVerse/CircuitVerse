---
sidebar_position: 5
---

# Web-First assertions for RSpec

Playwright introduces clever assertions for E2E testing, so called [web-first assertions](https://playwright.dev/docs/test-assertions).

```ruby
it 'should show username after login' do
  page.fill('input[name="username"]', 'playwright')
  page.fill('input[name="password"]', 'password123')
  page.expect_navigation do
    page.locator('button[type="submit"]').click
  end

  dashboard_container = page.locator('.dashboard')

  # Not web-first assertion
  expect(dashboard_container.text_content).to include('Hi, playwright!')

  # Web-first assertion
  expect(dashboard_container).to have_text('Hi, playwright!')
end
```

The spec above have 2 similar expectations. The first one is a normal assertion, which is not web-first. The second one is a web-first assertion, which is introduced by Playwright.

Imagine the case that 'Hi, playwright!' is shown after loading some data from API server. In this case, the first assertion may fail because 'Hi, playwright!' is not present soon after login. On the other hand, the second assertion automatically waits for the 'Hi, playwright!' to be shown.

## Configure

For avoiding matcher name conflicts, web-first assertions are not loaded by default. To enable web-first assertions, we have to configure RSpec as below:

```ruby title=spec/support/web_first_assertion.rb
require 'playwright/test'

RSpec.configure do |config|
  # include web-first assertions just for feature specs.
  config.include Playwright::Test::Matchers, type: :feature
end
```

If you want to use web-first assertions only for some specs, you can include `Playwright::Test::Matchers` in the spec file directly.

```ruby title=spec/system/example_spec.rb
require 'rails_helper'
require 'playwright/test'

describe 'example' do
  include Playwright::Test::Matchers

  it 'should work' do
    ...
```

## Matchers

Please refer to [API doc](/docs/api/locator_assertions).
