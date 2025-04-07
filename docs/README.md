## Setup CircuitVerse API documentation

### Prerequisites

You're going to need:

- **Linux or macOS** — Windows may work, but is unsupported.
- **Ruby, version 2.3.1 or newer**
- **Bundler** — If Ruby is already installed, but the `bundle` command doesn't work, just run `gem install bundler` in a terminal.

### Getting Set Up

1. Setup CircuitVerse, refer [`SETUP.md`](../SETUP.md)
2. `cd CircuitVerse/docs`
3. Initialize and start Slate. You can either do this locally, or with Vagrant:

```shell
# either run this to run locally
bundle install
bundle exec middleman server

# OR run this to run with vagrant
vagrant up
```

You can now see the docs at http://localhost:4567.
---

### 💡 Fix for `node-sass` Installation Error on Windows

If you encounter an error related to `node-sass` during `npm install`, it may be due to `node-gyp` or Python compatibility issues on Windows.

To fix this, uninstall `node-sass` and install the `sass` package instead:

```bash
npm uninstall node-sass
npm install sass

