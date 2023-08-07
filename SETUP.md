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
| Docker Development Environment | Windows | [Click Here](https://github.com/tanmoysrt/CircuitVerse/tree/master/installation_docs/docker.md#windows) |
| Docker Development Environment | Linux | [Click Here](https://github.com/tanmoysrt/CircuitVerse/tree/master/installation_docs/docker.md#linux) |
| Docker Development Environment | Mac | [Click Here](https://github.com/tanmoysrt/CircuitVerse/tree/master/installation_docs/docker.md#macos) |
| Manual Setup | Windows | [Click Here]() |
| Manual Setup | Linux | [Click Here]() |
| Manual Setup | Mac | [Click Here]() |

### CircuitVerse API documentation
CircuitVerse API documentation is available at - https://api.circuitverse.org/

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

## API Setup
CircuitVerse API uses `RSASSA` cryptographic signing that requires `private` and associated `public` key. To generate the keys RUN the following commands in `CircuitVerse/`
```
openssl genrsa -out config/private.pem 2048
openssl rsa -in config/private.pem -outform PEM -pubout -out config/public.pem
```

## Tests
Before making a pull request, it is a good idea to check that all tests are passing locally.

- To run the system tests, run `bundle exec rspec` .
- To run the simulator tests, run `yarn run test` .

**Note:** To pass the system tests, you need the [Chrome Browser](https://www.google.com/chrome/) installed.


## Deployment Guide
### Heroku Deployment
[Heroku](https://www.heroku.com) is a free cloud platform that can be used for deployment of CircuitVerse

You will be redirected to the Heroku page for deployment on clicking the below button. Make sure that you fill in the `Config Vars` section before deploying it.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CircuitVerse/CircuitVerse)


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
