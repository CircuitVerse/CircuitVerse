---
sidebar_position: 1
---

# Download Playwright driver

`playwright-ruby-client` doesn't include Playwright driver nor its downloader. **We have to install Playwright in advance**, and set the proper CLI path like `Playwright.create(playwright_cli_executable_path: /path/to/playwright)`

Choose any of the three ways as you prefer to download the driver:

- `npx`: suitable for playground use, and not suitable for continuous usage.
- `npm install`: the best choice for most use cases, with existing Node.js environment.
- Direct download: maybe a good choice for Docker :whale: integration.

:::note

Also the article [Playwright on Alpine Linux](./playwright_on_alpine_linux) would be helpful if you plan to

- Build a browser server/container like Selenium Grid
- Run automation scripts on Alpine Linux

:::

## Using `npx`

```shell
$ npx playwright install
```

and then set `playwright_cli_executable_path: "npx playwright"` at `Playwright.create`.

## Using `npm install`

Actually `npx playwright` is a bit slow. We can also use `npm install` to setup.

Instead of `npx playwright install`:

```shell
$ export PLAYWRIGHT_CLI_VERSION=$(bundle exec ruby -e 'puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip')
$ npm install playwright@$PLAYWRIGHT_CLI_VERSION || npm install playwright@next
$ ./node_modules/.bin/playwright install
```

and then set `playwright_cli_executable_path: './node_modules/.bin/playwright'`

## Directly download driver without Node.js installation.

Instead of npm, you can also directly download playwright driver from playwright.azureedge.net. (The URL can be easily detected from [here](https://github.com/microsoft/playwright-python/blob/cfc1030a69d1e934cac579687a680eac53d4b9ee/setup.py#L75))

```shell
$ export PLAYWRIGHT_CLI_VERSION=$(bundle exec ruby -e 'puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip')
$ wget https://playwright.azureedge.net/builds/driver/playwright-$PLAYWRIGHT_CLI_VERSION-linux.zip
```

and then extract it, and set `playwright_cli_executable_path: '/path/to/playwright-$PLAYWRIGHT_CLI_VERSION-linux/node /path/to/playwright-$PLAYWRIGHT_CLI_VERSION-linux/package/cli.js'`
