# Setting up CircuitVerse
[Back to `README.md`](README.md)

Please go through the [Contribution Guidelines](CONTRIBUTING.md) before going forward with any development. This helps us keep the process streamlined and results in better PRs.

If you have any setup problems, please ensure you have read through all the instructions and have all the required software installed before creating an issue.

---

## Note
If you are facing any issues with the setup, first check out the [troubleshooting guide](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/troubleshooting_guide.md) and if you are still facing issues, feel free to ask in the [Slack](https://github.com/CircuitVerse/CircuitVerse/blob/master/README.md#community) channel.

## Installation
There are several ways to run a local instance of CircuitVerse:

| Operating System | Method | Documentation |
| --- | --- | --- |
| Any | GitHub Codespaces | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/remote_development.md#github-codespaces) |
| Mac | Native Setup | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/manual/mac.md) |
| Mac | Docker Development Environment | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/docker.md#macos) |
| Linux | Native Setup | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/manual/linux.md) |
| Linux | Docker Development Environment | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/docker.md#linux) |
| Windows | Docker Development Environment | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/docker.md#windows) |
| Windows | WSL Setup | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/manual/windows-wsl.md) |
| Windows | Native Setup | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/manual/windows.md) |


## Tools Setup
| Tool | Documentation Link |
| --- | --- |
| Code Auto Completion | [Click Here](https://github.com/CircuitVerse/CircuitVerse/blob/master/LSP-SETUP.md) |
| Ruby Debugger | [Click Here](https://github.com/CircuitVerse/CircuitVerse/blob/master/DEBUGGER-SETUP.md) |

## Tests
Before making a pull request, it is a good idea to check that all tests are passing locally.

- To run the system tests, run `bundle exec rspec` .
- To run the simulator tests, run `yarn run test` .

**Note:** To pass the system tests, you need the [Chrome Browser](https://www.google.com/chrome/) installed. For docker based setup, you can ignore this.


## CircuitVerse API documentation
CircuitVerse API documentation is available at - https://api.circuitverse.org/

If you would like to set up CircuitVerse API documentation locally, refer to [docs/README.md](docs/README.md)


### Enabling/Disabling features with Flipper 
By default `:forum` and `:recaptcha` features are set to false. These can be enabled either via rails console or Flipper dashboard.
```ruby
rails c

# Enable features (:recaptcha, :forum)
> Flipper.enable :recaptcha

# Disable features (:project_comments, :lms_integration)
> Flipper.disable :forum
```
Flipper dashboard can be accessed at - http://localhost:3000/flipper/ from where following features can be enabled/disabled.

**Note:** User needs to log in as admin first; only then can the Flipper dashboard be accessed.
If you have followed the provided setup documentation, you can log in as admin with following credentials.
```
User: Admin
Email: admin@circuitverse.org
Password: password
```

### Production
The following commands should be run for production:
```
bundle install --with pg --without development test
RAILS_ENV=production bundle exec rake assets:precompile
bundle exec sidekiq -e production -q default -q mailers -d -L tmp/sidekiq.log
```

## Third Party Services
The `.env` file only needs to be used if you would like to link to third party services (Facebook, Google, GitHub, Gitlab, Slack, Bugsnap and Recaptcha)

1. Create an app on the third party service [(instructions)](https://github.com/CircuitVerse/CircuitVerse/wiki/Create-Apps)
2. Make the following changes in your Google, Facebook, GitHub or Gitlab app:
   1.  Update the `site url` field with the URL of your instance, and update the `callback url` field with `<url>/users/auth/google`, `<url>/users/auth/facebook`, `<url>/users/auth/github` or `<url>/users/auth/gitlab`  respectively.
3. Configure your `id` and `secret` environment variables in `.env`. If `.env` does not exist, copy the template from `.env.example`.
4. After adding the environment variables, run `dotenv rails server` to start the application.

## (Optional) Yosys Installation for Verilog RTL Synthesis
If you wish to do Verilog RTL Synthesis/create CircuitVerse Verilog Circuits in your local development environment, you need to install the `yosys` binary.

> **Note:** The Verilog-to-DigitalJS conversion logic is now bundled as a vendored Ruby Gem (`yosys2digitaljs`). You no longer need to run a separate server.

### Installation steps

1. **Install yosys**
   - **Docker Users:** `yosys` is pre-installed in the Docker image. No action needed.
   - **Debian/Ubuntu:**
     ```sh
     sudo apt install yosys
     ```
   - **macOS (Homebrew):**
     ```sh
     brew install yosys
     ```
   - **Other Platforms:** Download and install the [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build/releases/latest).

2. **Verify Installation:**
   ```sh
   yosys -V
   # Should output version info, e.g., "Yosys 0.9+..."
   ```

That's it! The CircuitVerse application will automatically use the `yosys` binary via the bundled gem.

## Distributed Tracing using OpenTelemetry

Refer [otel docs](./.otel)
