# Setting up CircuitVerse
[Back to `README.md`](README.md)

Please go through the [Contribution Guidelines](CONTRIBUTING.md) before going forward with any development. This helps us keep the process streamlined and results in better PRs.

If you have any setup problems, please ensure you have read through all the instructions have all the required software installed before creating an issue.

---

## Note
If you are facing any issues with the setup, first checkout the [troubleshooting guide](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/troubleshooting_guide.md) and if you are still facing issues, feel free to ask in the [slack](https://github.com/CircuitVerse/CircuitVerse/blob/master/README.md#community) channel.

## Installation
There are several ways to run your own instance of CircuitVerse:

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

If you like to setup CircuitVerse API documentation locally, refer [docs/README.md](docs/README.md)


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

**Note :** User need to log in as admin first, then only Flipper dashboard can be accessed
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

## (Optional) yosys installation for Verilog RTL Synthesis
If you wish to do Verilog RTL Synthesis/create CircuitVerse Verilog Circuits in your local development environment, you need to:
1. Install yosys
2. Setup and run CircuitVerse's yosys2digitaljs-server.

### Installation steps
1. **Install yosys**
   - Many Linux distibutions provide yosys binaries which is easy to install & small in package size. For Example,
**For Debina/Ubunutu**:
  ```sudo apt install yosys```
   - For other linux distributions, MacOS, & Windows OS, you need to install the OSS CAD Suite
      1. Download an archive matching your OS from [the releases page](https://github.com/YosysHQ/oss-cad-suite-build/releases/latest).
      2. Extract the archive to a location of your choice (for Windows it is recommended that path does not contain spaces)
      3. To use OSS CAD Suite

      **Other Linux distros and macOS**
      ```shell
      export PATH="<extracted_location>/oss-cad-suite/bin:$PATH"

      or

      source <extracted_location>/oss-cad-suite/environment
      ```
      **Windows**
      ```
      from existing shell:
      <extracted_location>\oss-cad-suite\environment.bat

      to create new shell window:
      <extracted_location>\oss-cad-suite\start.bat
      ```

2. **Setup CircuitVerse yosys2digitaljs-server**
    - In your local CircuitVerse Repository:
      ```sh
      git clone https://github.com/CircuitVerse/yosys2digitaljs-server.git

      cd yosys2digitaljs-server

      yarn

      cd ..
      ```
    - To use CircuitVerse yosys2digitaljs-server:
      ```sh
      bin/yosys
      ```

## Distributed Tracing using Opentelmetry

Refer [otel docs](./.otel)
