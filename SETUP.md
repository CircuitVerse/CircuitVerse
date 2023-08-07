# Setting up CircuitVerse
[Back to `README.md`](README.md)

Please go through the [Contribution Guidelines](CONTRIBUTING.md) before going forward with any development. This helps us keep the process streamlined and results in better PRs.

If you have any setup problems, please ensure you have read through all the instructions have all the required software installed before creating an issue.

---

## Installation
There are several ways to run your own instance of CircuitVerse:

| Method | Operating System | Documentation |
| --- | --- | --- |
| Github Codespaces | Any | [Click Here](https://github.com/tanmoysrt/CircuitVerse/tree/master/installation_docs/remote_development.md#github-codespaces) |
| Gitpod Cloud Environment | Any | [Click Here](https://github.com/tanmoysrt/CircuitVerse/tree/master/installation_docs/remote_development.md#gitpod-cloud-environment) |
| Docker Development Environment | Windows | [Click Here]() |
| Docker Development Environment | Linux | [Click Here]() |
| Docker Development Environment | Mac | [Click Here]() |
| Manual Setup | Windows | [Click Here]() |
| Manual Setup | Linux | [Click Here]() |
| --- | --- | --- |

#### (Optional) yosys installation for Verilog RTL Synthesis
If you wish to do Verilog RTL Synthesis/create CircuitVerse Verilog Circuits in your local development environment, you need to:
1. Install yosys
2. Setup and run CircuitVerse's yosys2digitaljs-server.

##### Installation steps
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
1. **Setup CircuitVerse yosys2digitaljs-server**
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

### CircuitVerse API documentation setup instructions
To setup CircuitVerse API documentation, refer [docs/README.md](docs/README.md)

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

### Additional setup instructions
[Yarn](https://yarnpkg.com/lang/en/) is a package manager for the JavaScript ecosystem.
CircuitVerse uses Yarn for frontend package and asset management.
  - Removing RVM
    ```
    sudo apt-get --purge remove ruby-rvm
    sudo rm -rf /usr/share/ruby-rvm /etc/rvmrc /etc/profile.d/rvm.sh
    ```
  - Installing new version of RVM
    ```
    curl -L https://get.rvm.io |
    bash -s stable --ruby --autolibs=enable --auto-dotfiles
    ```
### Heroku Deployment
[Heroku](https://www.heroku.com) is a free cloud platform that can be used for deployment of CircuitVerse

You will be redirected to the Heroku page for deployment on clicking the below button. Make sure that you fill in the `Config Vars` section before deploying it.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CircuitVerse/CircuitVerse)


## Development
To seed the database with some sample data, run `bundle exec rake db:seed`. This will add the following admin credentials:
```
User: Admin
Email: admin@circuitverse.org
Password: password
```

## Production
The following commands should be run for production:
```
bundle install --with pg --without development test
RAILS_ENV=production bundle exec rake assets:precompile
bundle exec sidekiq -e production -q default -q mailers -d -L tmp/sidekiq.log
```


## Tests

Before making a pull request, it is a good idea to check that all tests are passing locally.

- To run the system tests, run `bundle exec rspec` .
- To run the simulator tests, run `yarn run test` .

**Note:** To pass the system tests, you need the [Chrome Browser](https://www.google.com/chrome/) installed.


## API Setup
CircuitVerse API uses `RSASSA` cryptographic signing that requires `private` and associated `public` key. To generate the keys RUN the following commands in `CircuitVerse/`
```
openssl genrsa -out config/private.pem 2048
openssl rsa -in config/private.pem -outform PEM -pubout -out config/public.pem
```

## Third Party Services
The `.env` file only needs to be used if you would like to link to third party services (Facebook, Google, GitHub, Gitlab, Slack, Bugsnap and Recaptcha)

1. Create an app on the third party service [(instructions)](https://github.com/CircuitVerse/CircuitVerse/wiki/Create-Apps)
2. Make the following changes in your Google, Facebook, GitHub or Gitlab app:
   1.  Update the `site url` field with the URL of your instance, and update the `callback url` field with `<url>/users/auth/google`, `<url>/users/auth/facebook`, `<url>/users/auth/github` or `<url>/users/auth/gitlab`  respectively.
3. Configure your `id` and `secret` environment variables in `.env`. If `.env` does not exist, copy the template from `.env.example`.
4. After adding the environment variables, run `dotenv rails server` to start the application.
