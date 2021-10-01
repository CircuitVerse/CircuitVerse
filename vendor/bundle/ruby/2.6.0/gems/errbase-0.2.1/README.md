# Errbase

Common exception reporting for a variety of services

Libraries are automatically detected. Supports:

- [Airbrake](https://airbrake.io/)
- [Appsignal](https://appsignal.com/)
- [Bugsnag](https://bugsnag.com/)
- [Exception Notification](https://github.com/smartinez87/exception_notification)
- [Google Stackdriver](https://cloud.google.com/stackdriver/)
- [Honeybadger](https://www.honeybadger.io/)
- [New Relic](https://newrelic.com/)
- [Raygun](https://raygun.io/)
- [Rollbar](https://rollbar.com/)
- [Sentry](https://getsentry.com/)

```ruby
begin
  # code
rescue => e
  Errbase.report(e)
end
```

You can add extra context with:

```ruby
Errbase.report(e, {username: "hello"})
```

> Context is not supported for Google Stackdriver

## Installation

Errbase is designed to be used as a dependency.

Add this line to your gemspec:

```ruby
spec.add_dependency "errbase"
```

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/errbase/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/errbase/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/errbase.git
cd errbase
bundle install
bundle exec rake test
```
