5.1.0 (2024-12-05)
------------------

* Feature - Support async job processing in Elastic Beanstalk middleware. (#167)

5.0.0 (2024-11-21)
------------------

* Feature - [Major Version] Remove dependencies on modular feature gems: `aws-actiondispatch-dynamodb`, `aws-actionmailer-ses`, `aws-actionmailbox-ses`, `aws-activejob-sqs`, and `aws-record-rails`.

* Issue - Remove `Aws::Rails.add_action_mailer_delivery_method` in favor of `ActionMailer::Base.add_delivery_method` or the Railtie and configuration in `aws-actionmailer-ses ~> 1`.

* Issue - Remove require of `aws/rails/action_mailbox/rspec` in favor of `aws/action_mailbox/ses/rspec`.

* Issue - Remove symlinked namespaces from previous major versions.

* Feature - `ActiveSupport::Notifications` are enabled by default and removes `Aws::Rails.instrument_sdk_operations`.

* Feature - Moved railtie initializations to their appropriate spots.

* Issue - Do not execute `ActiveJob` from EB cron without the root path.

4.2.0 (2024-11-20)
------------------

* Feature - DynamoDB Session Storage features now live in the `aws-actiondispatch-dynamodb` gem. This gem depends on `aws-sessionstore-dynamodb ~> 3` which depends on `rack ~> 3`.

* Feature - Add session store config generation with `rails generate dynamo_db:session_store_config`. Config generation is no longer tied to the DynamoDB SessionStore ActiveRecord migration generator.

* Issue - `ActionDispatch::Session::DynamoDbStore` now inherits `ActionDispatch::Session::AbstractStore` by wrapping `Aws::SessionStore::DynamoDB::RackMiddleware`.

* Issue - `DynamoDbStore` is now configured with the `:dynamo_db_store` configuration instead of `:dynamodb_store`.

* Feature - Session Store configuration passed into `:dynamo_db_store` in an initializer will now be considered when using the ActiveRecord migrations or rake tasks that create, delete, or clean session tables.

* Feature - `AWS_DYNAMO_DB_SESSION_CONFIG_FILE` is now searched and with precedence over the default Rails configuration YAML file locations.

* Feature - Prepare modularization of `aws-record`.

* Issue - Do not skip autoload modules for `Aws::Rails.instrument_sdk_operations`.

* Feature - ActionMailer SES and SESV2 mailers now live in the `aws-actionmailer-ses` gem.

* Feature - New namespace and class names for SES and SESV2 mailers. `Aws::Rails::SesMailer` has been moved to `Aws::ActionMailer::SES::Mailer` and `Aws::Rails::Sesv2Mailer` has been moved to `Aws::ActionMailer::SESV2::Mailer`. The classes have been symlinked for backwards compatibility in this major version.

* Issue - Add deprecation warning to `Aws::Rails.add_action_mailer_delivery_method` to instead use `ActionMailer::Base.add_delivery_method`. This method will be removed in aws-sdk-rails ~> 5.

* Feature - ActionMailbox SES ingress now lives in the `aws-actionmailbox-ses` gem.

* Issue - The `Aws::Rails::ActionMailbox::RSpec` module has been moved to `Aws::ActionMailbox::SES::RSpec` and will be removed in aws-sdk-rails ~> 5.

* Feature - ActiveJob SQS now lives in the `aws-activejob-sqs` gem.

* Feature - New namespace and class names for SQS ActiveJob. Existing namespace has temporarily been kept for backward compatibility and will be removed in aws-sdk-rails ~> 5.

* Issue - Correctly determine if SQSD is running in a Docker container.

* Feature - Aws::Record scaffold generators now lives in the `aws-record-rails` gem.

4.1.0 (2024-09-27)
------------------

* Feature - Add SDK eager loading to optimize load times.  See: https://github.com/aws/aws-sdk-ruby/pull/3105.

4.0.3 (2024-07-31)
------------------

* Issue - Revert validating `:ses` or `:sesv2` as ActionMailer configuration. (#136)

4.0.2 (2024-07-22)
------------------

* Issue - Do not require `action_mailbox/engine` in `Aws::Rails::ActionMailbox::Engine` and instead check for its existence.

* Issue - Refactor the loading of the SQS ActiveJob adapter to be in `aws/rails/sqs_active_job`.

4.0.1 (2024-07-18)
------------------

* Issue - Require `action_mailbox/engine` from `Aws::Rails::ActionMailbox::Engine`.

4.0.0 (2024-07-18)
------------------

* Feature - Add support for Action Mailbox with SES (#127).

* Issue - Ensure `:ses` or `:sesv2` as ActionMailer configuration.

* Issue - Do not allow `:amazon`, `amazon_sqs`, or `amazon_sqs_async` for SQS active job configuration. Instead use `:sqs` and `:sqs_async`.

3.13.0 (2024-06-06)
------------------

* Feature - Use `Concurrent.available_processor_count` to set default thread pool max threads (#125).

* Issue - No longer rely on `caller_runs` for backpressure in sqs active job executor (#123).

3.12.0 (2024-04-02)
------------------
* Feature - Drop support for Ruby 2.3 and Ruby 2.4 (#117).
* Issue - Fix `EbsSqsActiveJobMiddleware` to detect Docker container with cgroup2. (#116).

3.11.0 (2024-03-01)
------------------

* Feature - Add `retry_standard_errors` (default `true`) in SQS ActiveJob and improve retry logic (#114).

3.10.0 (2024-01-19)
------------------

* Feature - Support `enqueue_all` in the SQS ActiveJob adapter. 

* Issue - Improve `to_h` method's performance of `Aws::Rails::SqsActiveJob::Configuration`.

3.9.1 (2023-12-19)
------------------

* Issue - Fix negative `delay_seconds` being passed to parameter in the SQS adapter.

3.9.0 (2023-09-28)
------------------

* Feature - Add support for selectively choosing deduplication keys.

* Feature - Set required Ruby version to >= 2.3 (#104)

* Issue - Run `rubocop` on all files. (#104)

3.8.0 (2023-06-02)
------------------

* Feature - Improve User-Agent tracking and bump minimum SQS and SES versions.

3.7.1 (2023-02-15)
------------------

* Issue - Fix detecting docker host in `EbsSqsActiveJobMiddleware`.

3.7.0 (2023-01-24)
------------------

* Feature - Add SES v2 Mailer.

* Feature - Support smtp_envelope_from and _to in SES Mailer.

* Issue - Fix Ruby 3.1 usage by handling Psych 4 BadAlias error.

3.6.4 (2022-10-13)
------------------

* Issue - Use `request.ip` in `sent_from_docker_host?`.

3.6.3 (2022-09-06)
------------------

* Issue - Remove defaults for `visibility_timeout`: fallback to value configured on queue.
* Issue - Fix I18n localization bug in SQS adapters.

3.6.2 (2022-06-16)
------------------

* Issue - Fix DynamoDB session store to work with Rails 7.
* Issue - Allow for dynamic message group ids in FIFO Queues.

3.6.1 (2021-06-08)
------------------

* Issue - Fix credential loading to work with Rails 7.

3.6.0 (2021-01-20)
------------------

* Feature - Support for forwarding Elastic Beanstalk SQS Daemon requests to Active Job.

3.5.0 (2021-01-06)
------------------

* Feature - Add support for FIFO Queues to AWS SQS ActiveJob.

3.4.0 (2020-12-07)
------------------

* Feature - Add a non-blocking async ActiveJob adapter: `:amazon_sqs_async`.

* Feature - Add a lambda handler for processing active jobs from an SQS trigger.

* Issue - Fix bug in default for backpressure config.

3.3.0 (2020-12-01)
------------------

* Feature - Add `aws-record` as a dependency, a rails generator for `aws-record` models, and a rake task for table migrations.

* Feature - Add AWS SQS ActiveJob - A lightweight, SQS backend for ActiveJob.

3.2.1 (2020-11-13)
------------------

* Issue - Include missing files into the gemspec.

3.2.0 (2020-11-13)
------------------

* Feature - Add support for `ActiveSupport::Notifications` for instrumenting AWS SDK service calls.

* Feature - Add support for DynamoDB as an `ActiveDispatch::Session`.

3.1.0 (2020-04-06)
------------------
* Issue - Merge only credential related keys from Rails encrypted credentials into `Aws.config`.

3.0.5 (2019-10-17)
------------------

* Upgrading - Adds support for Rails Encrypted Credentials, requiring Rails 5.2+
and thus needed a new major version. Consequently drops support for Ruby < 2.3
and for Rails < 5.2. Delivery method configuration changed from `:aws_sdk` to
`:ses`, to allow for future delivery methods. Adds rubocop to the package and
fixed many violations. This test framework now includes a dummy application for
testing future features.

2.1.0 (2019-02-14)
------------------

* Feature - Aws::Rails::Mailer - Adds the Amazon SES message ID as a header to
raw emails after sending, for tracking purposes. See
[related GitHub pull request #25](https://github.com/aws/aws-sdk-rails/pull/25).

2.0.1 (2017-10-03)
------------------

* Issue - Ensure `aws-sdk-rails.initialize` executes before
`load_config_initializers`

2.0.0 (2017-08-29)
------------------

* Upgrading - Support version 3 of the AWS SDK for Ruby. This is being released
as major version 2 of `aws-sdk-rails`, though the APIs remain the same. Do note,
however, that we've changed our SDK dependency to only depend on `aws-sdk-ses`.
This means that if you were depending on other service clients transitively via
`aws-sdk-rails`, you will need to add dependencies on the appropriate service
gems when upgrading. Logger integration will work for other service gems you
depend on, since it is wired up against `aws-sdk-core` which is included in
the `aws-sdk-ses` dependency.

1.0.1 (2016-02-01)
------------------

* Feature - Gemfile - Replaced `rails` gem dependency with `railties`
  dependency. With this change, applications that bring their own dependencies
  in place of, for example, ActiveRecord, can do so with reduced bloat.

  See [related GitHub pull request
  #4](https://github.com/aws/aws-sdk-rails/pull/4).

1.0.0 (2015-03-17)
------------------

* Initial Release: Support for Amazon Simple Email Service and Rails Logger
  integration.
