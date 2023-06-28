Changelog
=========

## v6.24.2 (21 January 2022)

### Fixes

* Avoid rescuing from errors in Active Record transaction callbacks in versions of Rails where they will be re-raised
  | [#709](https://github.com/bugsnag/bugsnag-ruby/pull/709)
  | [apalmblad](https://github.com/apalmblad)

## v6.24.1 (30 November 2021)

### Fixes

* Fix metadata not being recorded when using Resque outside of Active Job
  | [#710](https://github.com/bugsnag/bugsnag-ruby/pull/710)
  | [isnotajoke](https://github.com/isnotajoke)

## v6.24.0 (6 October 2021)

### Enhancements

* Allow overriding an event's unhandled flag
  | [#698](https://github.com/bugsnag/bugsnag-ruby/pull/698)
* Add the ability to store metadata globally
  | [#699](https://github.com/bugsnag/bugsnag-ruby/pull/699)
* Add `cookies`, `body` and `httpVersion` to the automatically captured request data for Rack apps
  | [#700](https://github.com/bugsnag/bugsnag-ruby/pull/700)
* Add `Configuration#endpoints` for reading the notify and sessions endpoints and `Configuration#endpoints=` for setting them
  | [#701](https://github.com/bugsnag/bugsnag-ruby/pull/701)
* Add `Configuration#redacted_keys`. This is like `meta_data_filters` but matches strings with case-insensitive equality, rather than matching based on inclusion
  | [#703](https://github.com/bugsnag/bugsnag-ruby/pull/703)
* Allow pausing and resuming sessions, giving more control over the stability score
  | [#704](https://github.com/bugsnag/bugsnag-ruby/pull/704)
* Add `Configuration#vendor_paths` to replace `Configuration#vendor_path`
  | [#705](https://github.com/bugsnag/bugsnag-ruby/pull/705)

### Deprecated

* In the next major release, `params` will only contain query string parameters. Currently it also contains the request body for form data requests, but this is deprecated in favour of the new `body` property
* The `Configuration#set_endpoints` method is now deprecated in favour of `Configuration#endpoints=`
* The `Configuration#meta_data_filters` option is now deprecated in favour of `Configuration#redacted_keys`
* The `Configuration#vendor_path` option is now deprecated in favour of `Configuration#vendor_paths`

## v6.23.0 (21 September 2021)

### Enhancements

* Sessions will now be delivered every 10 seconds, instead of every 30 seconds
  | [#680](https://github.com/bugsnag/bugsnag-ruby/pull/680)
* Log errors that prevent delivery at `ERROR` level
  | [#681](https://github.com/bugsnag/bugsnag-ruby/pull/681)
* Add `on_breadcrumb` callbacks to replace `before_breadcrumb_callbacks`
  | [#686](https://github.com/bugsnag/bugsnag-ruby/pull/686)
* Add `context` attribute to configuration, which will be used as the default context for events. Using this option will disable automatic context setting
  | [#687](https://github.com/bugsnag/bugsnag-ruby/pull/687)
  | [#688](https://github.com/bugsnag/bugsnag-ruby/pull/688)
* Add `Bugsnag#breadcrumbs` getter to fetch the current list of breadcrumbs
  | [#689](https://github.com/bugsnag/bugsnag-ruby/pull/689)
* Add `time` (an ISO8601 string in UTC) to `device` metadata
  | [#690](https://github.com/bugsnag/bugsnag-ruby/pull/690)
* Add `errors` to `Report`/`Event` containing an array of `Error` objects. The `Error` object contains `error_class`, `error_message`, `stacktrace` and `type` (always "ruby")
  | [#691](https://github.com/bugsnag/bugsnag-ruby/pull/691)
* Add `original_error` to `Report`/`Event` containing the original Exception instance
  | [#692](https://github.com/bugsnag/bugsnag-ruby/pull/692)
* Add `request` to `Report`/`Event` containing HTTP request metadata
  | [#693](https://github.com/bugsnag/bugsnag-ruby/pull/693)
* Add `add_metadata` and `clear_metadata` to `Report`/`Event`
  | [#694](https://github.com/bugsnag/bugsnag-ruby/pull/694)
* Add `set_user` to `Report`/`Event`
  | [#695](https://github.com/bugsnag/bugsnag-ruby/pull/695)

### Fixes

* Avoid starting session delivery thread when the current release stage is not enabled
  | [#677](https://github.com/bugsnag/bugsnag-ruby/pull/677)

### Deprecated

* `before_breadcrumb_callbacks` have been deprecated in favour of `on_breadcrumb` callbacks and will be removed in the next major release
* For consistency with Bugsnag notifiers for other languages, a number of methods have been deprecated in this release. The old options will be removed in the next major version | [#676](https://github.com/bugsnag/bugsnag-ruby/pull/676)
    * The `notify_release_stages` configuration option has been deprecated in favour of `enabled_release_stages`
    * The `auto_capture_sessions` and `track_sessions` configuration options have been deprecated in favour of `auto_track_sessions`
    * The `enabled_automatic_breadcrumb_types` configuration option has been deprecated in favour of `enabled_breadcrumb_types`
    * The `Report` class has been deprecated in favour of the `Event` class
    * The `Report#meta_data` attribute has been deprecated in favour of `Event#metadata`
    * The `Breadcrumb#meta_data` attribute has been deprecated in favour of `Breadcrumb#metadata`
    * The `Breadcrumb#name` attribute has been deprecated in favour of `Breadcrumb#message`
    * The breadcrumb type constants in the `Bugsnag::Breadcrumbs` module has been deprecated in favour of the constants available in the `Bugsnag::BreadcrumbType` module
    For example, `Bugsnag::Breadcrumbs::ERROR_BREADCRUMB_TYPE` is now available as `Bugsnag::BreadcrumbType::ERROR`
* `Report#exceptions` has been deprecated in favour of the new `errors` property
* `Report#raw_exceptions` has been deprecated in favour of the new `original_error` property
* Accessing request data via `Report#metadata` has been deprecated in favour of using the new `request` property. Request data will be moved out of metadata in the next major version
* The `Report#add_tab` and `Report#remove_tab` methods have been deprecated in favour of the new `add_metadata` and `clear_metadata` methods

## v6.22.1 (11 August 2021)

### Fixes

* Fix possible `LocalJumpError` introduced in v6.22.0
  | [#675](https://github.com/bugsnag/bugsnag-ruby/pull/675)

## v6.22.0 (10 August 2021)

### Enhancements

* Add support for tracking exceptions and capturing metadata in Active Job, when not using an existing integration
  | [#670](https://github.com/bugsnag/bugsnag-ruby/pull/670)

* Improve the report context when using Delayed Job or Resque as the Active Job queue adapter
  | [#671](https://github.com/bugsnag/bugsnag-ruby/pull/671)

## v6.21.0 (23 June 2021)

### Enhancements

* Allow a `Method` or any object responding to `#call` to be used as an `on_error` callback or middleware
  | [#662](https://github.com/bugsnag/bugsnag-ruby/pull/662)
  | [odlp](https://github.com/odlp)

### Fixes

* Deliver when an error is raised in the block argument to `notify`
  | [#660](https://github.com/bugsnag/bugsnag-ruby/pull/660)
  | [aki77](https://github.com/aki77)
* Fix potential `NoMethodError` in `Bugsnag::Railtie` when using `require: false` in a Gemfile
  | [#666](https://github.com/bugsnag/bugsnag-ruby/pull/666)

## v6.20.0 (29 March 2021)

### Enhancements

* Classify `ActionDispatch::Http::MimeNegotiation::InvalidType` as info severity level
  | [#654](https://github.com/bugsnag/bugsnag-ruby/pull/654)

### Fixes

* Include `connection_id` in ActiveRecord breadcrumb metadata on new versons of Rails
  | [#655](https://github.com/bugsnag/bugsnag-ruby/pull/655)
* Avoid crash when Mongo 1.12 or earlier is used
  | [#652](https://github.com/bugsnag/bugsnag-ruby/pull/652)
  | [isabanin](https://github.com/isabanin)

## 6.19.0 (6 January 2021)

### Enhancements

* Exception messages will be truncated if they have a length greater than 3,072
  | [#636](https://github.com/bugsnag/bugsnag-ruby/pull/636)
  | [joshuapinter](https://github.com/joshuapinter)

* Breadcrumb metadata can now contain any type
  | [#648](https://github.com/bugsnag/bugsnag-ruby/pull/648)

## 6.18.0 (27 October 2020)

### Enhancements

* Bugsnag should now report uncaught exceptions inside Bundler's 'friendly errors'
  | [#634](https://github.com/bugsnag/bugsnag-ruby/pull/634)

* Improve the display of breadrumbs in the Bugsnag app by including milliseconds in timestamps
  | [#639](https://github.com/bugsnag/bugsnag-ruby/pull/639)

## 6.17.0 (27 August 2020)

### Enhancements

* Sidekiq now uses `thread_queue` delivery by default
  | [#626](https://github.com/bugsnag/bugsnag-ruby/pull/626)

* Rescue now uses `thread_queue` delivery when `at_exit` hooks are enabled
  | [#629](https://github.com/bugsnag/bugsnag-ruby/pull/629)

## 6.16.0 (12 August 2020)

### Enhancements

* Set default Delayed Job error context to job class
  | [#499](https://github.com/bugsnag/bugsnag-ruby/pull/499)
  | [Mike Stewart](https://github.com/mike-stewart)

* The `BUGSNAG_RELEASE_STAGE` environment variable can now be used to set the release stage. Previously this was only used in Rails applications
  | [#613](https://github.com/bugsnag/bugsnag-ruby/pull/613)

* Add support for runtime versions to Delayed Job, Mailman and Shoryuken integrations
  | [#620](https://github.com/bugsnag/bugsnag-ruby/pull/620)

* Reduce the size of the bundled gem
  | [#571](https://github.com/bugsnag/bugsnag-ruby/pull/571)
  | [t-richards](https://github.com/t-richards)

* Move serialization of Reports onto the background thread when using the thread_queue delivery method
  | [#623](https://github.com/bugsnag/bugsnag-ruby/pull/623)

## Fixes

* The `app_type` configuration option should no longer be overwritten by Bugsnag and integrations should set this more consistently
  | [#619](https://github.com/bugsnag/bugsnag-ruby/pull/619)

## 6.15.0 (27 July 2020)

### Enhancements

* Add `on_error` callbacks to replace `before_notify_callbacks`
  | [#608](https://github.com/bugsnag/bugsnag-ruby/pull/608)

* Improve performance when extracting code from files in stacktraces
  | [#604](https://github.com/bugsnag/bugsnag-ruby/pull/604)

* Reduce memory use when session tracking is disabled
  | [#606](https://github.com/bugsnag/bugsnag-ruby/pull/606)

### Deprecated

* `before_notify_callbacks` have been deprecated in favour of `on_error` and will be removed in the next major release

## 6.14.0 (20 July 2020)

### Enhancements

* Add configurable `discard_classes` option to allow filtering errors using either a `String` or `Regexp` matched against the error's class name
  | [#597](https://github.com/bugsnag/bugsnag-ruby/pull/597)

* The Breadcrumb name limit of 30 characters has been removed
  | [#600](https://github.com/bugsnag/bugsnag-ruby/pull/600)

* Improve performance of payload cleaning
  | [#601](https://github.com/bugsnag/bugsnag-ruby/pull/601)

* Improve performance when processing stacktraces
  | [#602](https://github.com/bugsnag/bugsnag-ruby/pull/602)
  | [#603](https://github.com/bugsnag/bugsnag-ruby/pull/603)

* If a custom object responds to `id` method, show the id and class in error reports
  | [#531](https://github.com/bugsnag/bugsnag-ruby/pull/531)
  | [manojmj92](https://github.com/manojmj92)

### Deprecated

* The `ignore_classes` configuration option has been deprecated in favour of `discard_classes`. `ignore_classes` will be removed in the next major release

## 6.13.1 (11 May 2020)

### Fixes

* Only call custom diagnostic data methods once
  | [#586](https://github.com/bugsnag/bugsnag-ruby/pull/586)
  | [stoivo](https://github.com/stoivo)
* Guard against exceptions in to_s when cleaning objects
  | [#591](https://github.com/bugsnag/bugsnag-ruby/pull/591)

## 6.13.0 (30 Jan 2020)

### Enhancements

* Add configurable `vendor_path` to configure which file paths are out of project stacktrace.
  | [#544](https://github.com/bugsnag/bugsnag-ruby/pull/544)

### Fixes

* Resolve Ruby deprecation warning for keyword parameters
  | [#580](https://github.com/bugsnag/bugsnag-ruby/pull/582)

## 6.12.2 (24 Oct 2019)

### Fixes

* Handle change in capitalisation of framework version constant for Que in v1.x
  | [#570](https://github.com/bugsnag/bugsnag-ruby/pull/570)
  | [#572](https://github.com/bugsnag/bugsnag-ruby/pull/572)
  | [tommeier](https://github.com/tommeier)

## 6.12.1 (05 Sep 2019)

### Fixes

* Account for missing `:binds` key in `sql.active_record` ActiveSupport notifications.
  | [#555](https://github.com/bugsnag/bugsnag-ruby/issues/555)
  | [#565](https://github.com/bugsnag/bugsnag-ruby/pull/565)
* Remove duplicate attribute declaration warning for `track_sessions` in Configuration.
  | [#510](https://github.com/bugsnag/bugsnag-ruby/pull/510)
  | [pocke](https://github.com/pocke)

## 6.12.0 (28 Aug 2019)

### Enhancements

* Add Ruby (and other framework) version strings to report and session payloads (device.runtimeVersions).
  | [560](https://github.com/bugsnag/bugsnag-ruby/pull/560)

* Allow symbols in breadcrumb meta data.
  | [#563](https://github.com/bugsnag/bugsnag-ruby/pull/563)
  | [directionless](https://github.com/directionless)

### Fixes

* Use `Module#prepend` for Rake integration when on a new enough Ruby version
  to avoid infinite mutual recursion issues when something else monkey patches
  `Rake::Task`.
  | [#556](https://github.com/bugsnag/bugsnag-ruby/issues/556)
  | [#559](https://github.com/bugsnag/bugsnag-ruby/issues/559)

* Handle `nil` values for the `job` block parameter for the Que error notifier.
  This occurs under some conditions such as database connection failures.
  | [#545](https://github.com/bugsnag/bugsnag-ruby/issues/545)
  | [#548](https://github.com/bugsnag/bugsnag-ruby/pull/548)

## 6.11.1 (22 Jan 2019)

### Fixes

* Fix issue with unnecessary meta_data being logged during breadcrumb validation.
  | [#530](https://github.com/bugsnag/bugsnag-ruby/pull/530)

## 6.11.0 (17 Jan 2019)

**Note**: this release alters the behaviour of the notifier to track sessions automatically.

### Enhancements

* Added Breadcrumbs.  Breadcrumbs allow you to track events that may have led
up to an error, such as handled errors, page redirects, or SQL queries. For info on what
is tracked and how you can customize the data that breadcrumbs collect, see the
[Logging breadcrumbs](https://docs.bugsnag.com/platforms/ruby/other#logging-breadcrumbs)
section of our documentation.
  | [#525](https://github.com/bugsnag/bugsnag-ruby/pull/525)

* Bugsnag will now capture automatically created sessions by default.
  | [#523](https://github.com/bugsnag/bugsnag-ruby/pull/523)

### Deprecated

* The `endpoint` and `session_endpoint` configuration options are now deprecated but still supported. The [`set_endpoints`](https://docs.bugsnag.com/platforms/ruby/other/configuration-options#endpoints) method should be used instead. Note that session tracking will be disabled if the notify endpoint is configured but the sessions endpoint is not - this is to avoid inadvertently sending session payloads to the wrong server.

## 6.10.0 (05 Dec 2018)

### Enhancements

* Add SignalException to our default ignored classes
  | [#479](https://github.com/bugsnag/bugsnag-ruby/pull/479)
  | [Toby Hsieh](https://github.com/tobyhs)

* Include Bugsnag frames, marked out of project
  | [#497](https://github.com/bugsnag/bugsnag-ruby/pull/497)

### Fixes

* Ensure Sidekiq request data is always attached to notifications
  | [#495](https://github.com/bugsnag/bugsnag-ruby/pull/495)

## 6.9.0 (12 Nov 2018)

### Enhancements

* Ensure the correct error handler is used in newer versions of Sidekiq
  | [#434](https://github.com/bugsnag/bugsnag-ruby/pull/434)

* Rewrite Delayed::Job integration to fix potential issues and add more
  collected data
  | [#492](https://github.com/bugsnag/bugsnag-ruby/pull/492)
  | [Simon Maynard](https://github.com/snmaynard)

## 6.8.0 (11 Jul 2018)

This release includes general performance improvements to payload trimming and
filtering.

### Enhancements

* Capture unexpected app terminations automatically with `at_exit`
  | [#397](https://github.com/bugsnag/bugsnag-ruby/pull/397)
  | [Alex Moinet](https://github.com/Cawllec)

* (DelayedJob) Improve max attempts handling - If the max attempts method
  returns nil it should fallback to `Delayed::Worker.max_attempts`
  | [#471](https://github.com/bugsnag/bugsnag-ruby/pull/471)
  | [Johnny Shields](https://github.com/johnnyshields)

* Increase payload size limit to 512kb (from 256kb)
  | [#431](https://github.com/bugsnag/bugsnag-ruby/pull/431)
  | [Alex Moinet](https://github.com/Cawllec)

### Fixes

## 6.7.3 (18 May 2018)

### Fixes

* Apply metadata filters to HTTP referer fields
  | [#460](https://github.com/bugsnag/bugsnag-ruby/pull/460)
  | [Renee Balmert](https://github.com/tremlab)

## 6.7.2 (24 Apr 2018)

### Fixes

* (Notify) Handle `notify` calls with `nil` arguments correctly
  | [#439](https://github.com/bugsnag/bugsnag-ruby/pull/439)

## 6.7.1 (11 Apr 2018)

### Fixes

* (Rails) Log missing key warning after initialization completes, avoiding
  incorrectly logging a warning that the API key is missing
  | [#444](https://github.com/bugsnag/bugsnag-ruby/pull/444)

## 6.7.0 (05 Apr 2018)

### Enhancements

* Support HTTP proxy from `http_proxy` and `https_proxy` environment variables
  | [#424](https://github.com/bugsnag/bugsnag-ruby/pull/424)
  | [#437](https://github.com/bugsnag/bugsnag-ruby/pull/437)
  | [Bill Kirtley](https://github.com/cluesque)

* Add option to disable auto-configuration
  | [#419](https://github.com/bugsnag/bugsnag-ruby/pull/419)

* Add `warden.user.rack` data to default filters
  | [#436](https://github.com/bugsnag/bugsnag-ruby/pull/436)

### Fixes

* Ensure logged messages include Bugsnag progname
  | [#443](https://github.com/bugsnag/bugsnag-ruby/pull/443)

## 6.6.4 (14 Feb 2018)

### Fixes

* Mark files in `.bundle/` directory as not "in project"
  | [#420](https://github.com/bugsnag/bugsnag-ruby/pull/420)
  | [Alex Moinet](https://github.com/Cawllec)
* Restore support for attaching `bugsnag_*` metadata to exceptions without
  extending `Bugsnag::Middleware::ExceptionMetaData`
  | [#426](https://github.com/bugsnag/bugsnag-ruby/pull/426)
  | [Jordan Raine](https://github.com/jnraine)

## 6.6.3 (23 Jan 2018)

### Fixes

* Re-added apiKey to payload for compatibility
  | [#418](https://github.com/bugsnag/bugsnag-ruby/pull/418)


## 6.6.2 (18 Jan 2018)

### Fixes

* Fix Shoryuken integration & `project_root` `Pathname` issue
  | [#416](https://github.com/bugsnag/bugsnag-ruby/pull/416)
  | [Sergei Maximov](https://github.com/smaximov)

## 6.6.1 (09 Jan 2018)

### Bug fixes

* Fix failure to launch session polling task
  | [#414](https://github.com/bugsnag/bugsnag-ruby/pull/414)

## 6.6.0 (09 Jan 2018)

### Enhancements

* Session tracking update:
  * Refactor of session tracking to adhere to a common interface, and simplify usage.
  * Includes several performance enhancements.
  * Reverts potentially breaking change of json body sanitation within delivery function.
  | [#412](https://github.com/bugsnag/bugsnag-ruby/pull/412)
  * Maintains backwards compatibility with previous session-tracking changes.
  | [#413](https://github.com/bugsnag/bugsnag-ruby/pull/413)

## 6.5.0 (04 Jan 2018)

### Enhancements

* Adds support for tracking sessions and crash rate by setting the configuration option `configuration.auto_capture_sessions` to `true`.
  Sessions can be manually created using `Bugsnag.start_session`.
  | [#411](https://github.com/bugsnag/bugsnag-ruby/pull/411)

## 6.4.0 (21 Dec 2017)

### Enhancements

* Added support for DelayedJob custom job arguments
  | [#359](https://github.com/bugsnag/bugsnag-ruby/pull/359)
  | [Calvin Hughes](https://github.com/calvinhughes)

## 6.3.0 (14 Dec 2017)

### Enhancements

* Allow skipping report generation using exception property
  | [#402](https://github.com/bugsnag/bugsnag-ruby/pull/402)

## 6.2.0 (07 Dec 2017)

### Enhancements

* Added common exit exceptions - SystemExit and Interrupt - to default ignore classes.
  | [#404](https://github.com/bugsnag/bugsnag-ruby/pull/404)

## 6.1.1 (23 Nov 2017)

### Fixes

* Ensured Bugsnag class intialises before railties initialised
  | [#396](https://github.com/bugsnag/bugsnag-ruby/pull/396)

## 6.1.0 (17 Nov 2017)

### Enhancements

* Use lazy load hooks to hook on ActionController::Base
  | [Edouard-chin](https://github.com/Edouard-chin)
  | [#393](https://github.com/bugsnag/bugsnag-ruby/pull/393)

### Fixes

* Fix type in Rack/Clearance integration
  | [geofferymm](https://github.com/geoffreymm)
  | [#392](https://github.com/bugsnag/bugsnag-ruby/pull/392)

* Fix upgrade link to docs
  | [duncanhewett](https://github.com/duncanhewett)
  | [#390](https://github.com/bugsnag/bugsnag-ruby/pull/390)

## 6.0.1 (09 Nov 2017)

Adds a warning for the change in usage for the `notify()` method from < 6.0 to
ease upgrading.

## 6.0.0 (09 Nov 2017)

This notifier has been extensively re-written to make it easier to add new integrations and maintain in the future.  This has led to several changes that are not backwards compatible.  Please refer to the [upgrading guide](https://github.com/bugsnag/bugsnag-ruby/blob/master/UPGRADING.md) for more information.

### Enhancements

* General notifier re-write
  | [#320](https://github.com/bugsnag/bugsnag-ruby/pull/320)
  | [#378](https://github.com/bugsnag/bugsnag-ruby/pull/378)
  | [#368](https://github.com/bugsnag/bugsnag-ruby/pull/368)
  | [#381](https://github.com/bugsnag/bugsnag-ruby/pull/381)
  | [#385](https://github.com/bugsnag/bugsnag-ruby/pull/385)
  | [#386](https://github.com/bugsnag/bugsnag-ruby/pull/386)

* Added Upgrade guide
  | [#370](https://github.com/bugsnag/bugsnag-ruby/pull/370)

* Did-you-mean suggestions middleware
  | [#372](https://github.com/bugsnag/bugsnag-ruby/pull/372)

* Updated examples
  | [#374](https://github.com/bugsnag/bugsnag-ruby/pull/374)

## 5.5.0 (09 Nov 2017)

### Enhancements

* Allow environment variable proxy config for `Net::HTTP`
  | [dexhorthy](https://github.com/dexhorthy)
  | [#380](https://github.com/bugsnag/bugsnag-ruby/pull/380)

## 5.4.1 (06 Oct 2017)

### Fixes

* [DelayedJob] Fix `NameError` occurring on erroring job notification
  | [Eito Katagiri](https://github.com/eitoball)
  | [#377](https://github.com/bugsnag/bugsnag-ruby/pull/377)

* Fixed failing Rake/Java tests
  | [#378](https://github.com/bugsnag/bugsnag-ruby/pull/378)

## 5.4.0 (02 Oct 2017)

This release removes the default setting of ignoring classes of errors which are commonly associated with typos or server signals (`SystemExit`), instead recording them as `info`-level severity by default. This includes the following classes:

```
  AbstractController::ActionNotFound,
  ActionController::InvalidAuthenticityToken,
  ActionController::ParameterMissing,
  ActionController::RoutingError,
  ActionController::UnknownAction,
  ActionController::UnknownFormat,
  ActionController::UnknownHttpMethod,
  ActiveRecord::RecordNotFound,
  CGI::Session::CookieStore::TamperedWithCookie,
  Mongoid::Errors::DocumentNotFound,
  SignalException,
  SystemExit
```

### Enhancements

* Add a one-time warning if the API key is not set
* Track whether errors were captured automatically and by which middleware

## 5.3.3 (16 June 2017)

* [Rails] Fix failure to report when encountering objects which throw in `to_s`
  [#361](https://github.com/bugsnag/bugsnag-ruby/pull/361)

## 5.3.2 (27 April 2017)

### Bug fixes

* [Sidekiq] Revert commit [c7862ea](https://github.com/bugsnag/bugsnag-ruby/commit/c7862ea90397357f8daad8698c1572230f65075c)
  because Sidekiq's logging middleware was removed in version 5.0.0
  | [Reuben Brown](https://github.com/reubenbrown)
  | [#358](https://github.com/bugsnag/bugsnag-ruby/pull/358)

## 5.3.1 (20 April 2017)

### Bug fixes

* [Resque] Fix error when creating a worker without a queue
  | [Dean Galvin](https://github.com/FreekingDean)
  | [#355](https://github.com/bugsnag/bugsnag-ruby/pull/355)

## 5.3.0 (07 April 2017)

### Enhancements

* [Resque] Fix leaking config into parent process
  | [Martin Holman](https://github.com/martin308)
  | [#347](https://github.com/bugsnag/bugsnag-ruby/pull/347)
* Add new integration for Que
  | [Sjoerd Andringa](https://github.com/s-andringa)
  | [#305](https://github.com/bugsnag/bugsnag-ruby/pull/305)
* [Sidekiq] Start Bugsnag after the logger in the middleware chain
  | [Stephen Bussey](https://github.com/sb8244)
  | [Akhil Naini](https://github.com/akhiln)
  | [#326](https://github.com/bugsnag/bugsnag-ruby/pull/326)
  | [#350](https://github.com/bugsnag/bugsnag-ruby/pull/350)
* [Rake] Allow overriding `app_type` apps
  | [#351](https://github.com/bugsnag/bugsnag-ruby/issues/351)
* Send the dyno name as the hostname when running on Heroku
  | [#333](https://github.com/bugsnag/bugsnag-ruby/issues/333)
* [Delayed Job] Add additional job information such as arguments and number of
  attempts when available
  | [Tim Diggins](https://github.com/timdiggins)
  | [Abraham Chan](https://github.com/abraham-chan)
  | [Johnny Shields](https://github.com/johnnyshields)
  | [#329](https://github.com/bugsnag/bugsnag-ruby/pull/329)
  | [#332](https://github.com/bugsnag/bugsnag-ruby/pull/332)
  | [#321](https://github.com/bugsnag/bugsnag-ruby/pull/321)

### Bug fixes

* Initialize Railtie after Bugsnag class
  | [#343](https://github.com/bugsnag/bugsnag-ruby/issues/343)
* Alias `notify_or_ignore` to `notify`
  | [Simon Maynard](https://github.com/snmaynard)
  | [#319](https://github.com/bugsnag/bugsnag-ruby/pull/319)

## 5.2.0 (10 February 2017)

### Enhancements

* Allow provider attribute in Deploy#notify
  | [@jbaranov](https://github.com/jbaranov)
  | [#339](https://github.com/bugsnag/bugsnag-ruby/pull/339)

### Bug fixes

* Correctly hook on Action Controller
  | [@rafaelfranca](https://github.com/rafaelfranca)
  | [#338](https://github.com/bugsnag/bugsnag-ruby/pull/338)
* Fix Bugsnag error message typo
  | [@Adsidera](https://github.com/Adsidera)
  | [#344](https://github.com/bugsnag/bugsnag-ruby/pull/344)
* Default delivery method
  | [@martin308](https://github.com/martin308)
  | [#346](https://github.com/bugsnag/bugsnag-ruby/pull/346)

## 5.1.0 (23 January 2017)

### Bug fixes

* Fix behavior to not override Rails 5 `belongs_to` association
  | [#314](https://github.com/bugsnag/bugsnag-ruby/pull/314)

### Enhancements

* Add Clearance support
  | [Jonathan Rochkind](https://github.com/jrochkind)
  | [#313](https://github.com/bugsnag/bugsnag-ruby/pull/313)
* Add Shoruken support
  | [Nigel Ramsay](https://github.com/nigelramsay)
  | [#324](https://github.com/bugsnag/bugsnag-ruby/pull/324)

## 5.0.1 (7 September 2016)

### Bug fixes

* Show the job class name for Sidekiq jobs, not the wrapper class name
  | [Simon Maynard](https://github.com/snmaynard)
  | [#323](https://github.com/bugsnag/bugsnag-ruby/pull/323)

## 5.0.0 (23 August 2016)

### Enhancements

* Remove RoutingError from default ignore classes
  | [#308](https://github.com/bugsnag/bugsnag-ruby/issues/308)
* Prefer BUGSNAG_RELEASE_STAGE over RAILS_ENV for release_stage
  | [#298](https://github.com/bugsnag/bugsnag-ruby/issues/298)
* Apply grouping hash if method `bugsnag_grouping_hash` is available on the object
  | [#318](https://github.com/bugsnag/bugsnag-ruby/issues/318)
  | [#311](https://github.com/bugsnag/bugsnag-ruby/issues/311)
* Sidekiq improvements
  | [#317](https://github.com/bugsnag/bugsnag-ruby/issues/317)
  | [#282](https://github.com/bugsnag/bugsnag-ruby/issues/282)
  | [#309](https://github.com/bugsnag/bugsnag-ruby/issues/309)
  | [#306](https://github.com/bugsnag/bugsnag-ruby/issues/306)

### Fixes

* Exception backtrace could be empty
  | [#307](https://github.com/bugsnag/bugsnag-ruby/issues/307)

## 4.2.1 (23 Jun 2016)

### Fixes

* Ensure Rails 2 extensions are not loaded on newer versions
  | [#303](https://github.com/bugsnag/bugsnag-ruby/issues/303)

* Remove API key logging when Bugsnag is logging successfully
  | [Julian Borrey](https://github.com/jborrey)
  | [#299](https://github.com/bugsnag/bugsnag-ruby/pull/299)

## 4.2.0 (17 Jun 2016)

### Enhancements

* Add the name of the job class in context for Sidekiq and Resque errors
  | [Johan Lundström](https://github.com/johanlunds)
  | [#293](https://github.com/bugsnag/bugsnag-ruby/pull/293)

## 4.1.0 (11 May 2016)

### Enhancements

* Add support for 'block syntax' on Bugsnag.notify calls
  | [James Smith](https://github.com/loopj)
  | [#292](https://github.com/bugsnag/bugsnag-ruby/pull/292)

### Fixes

* Trim stacktraces and metadata to ensure payload delivery
  | [#294](https://github.com/bugsnag/bugsnag-ruby/issues/294)
  | [#295](https://github.com/bugsnag/bugsnag-ruby/pull/295)

## 4.0.2 (13 Apr 2016)

### Fixes

* Fix payload rejection due to truncating duplicate stacktrace frames
  | [#284](https://github.com/bugsnag/bugsnag-ruby/issues/284)
  | [#291](https://github.com/bugsnag/bugsnag-ruby/pull/291)

## 4.0.1 (5 Apr 2016)

### Fixes

* Fix Sidekiq app type being overwritten by Rails
  | [Luiz Felipe G. Pereira](https://github.com/Draiken)
  | [#286](https://github.com/bugsnag/bugsnag-ruby/pull/286)

* Fix report uploads being rejected due to payload size
  | [Ben Ibinson](https://github.com/CodeHex)
  | [Duncan Hewett](https://github.com/duncanhewett)
  | [#288](https://github.com/bugsnag/bugsnag-ruby/pull/288)
  | [#290](https://github.com/bugsnag/bugsnag-ruby/pull/290)

* Fix a possible crash when parsing a URL for RackRequest
  | [Max Schubert](https://github.com/perldork)
  | [#289](https://github.com/bugsnag/bugsnag-ruby/pull/289)

* Hide partial API key logged when loading Bugsnag
  | [#283](https://github.com/bugsnag/bugsnag-ruby/issues/283)

## 4.0.0 (9 Mar 2016)

This release includes general fixes as well as removing support
for Ruby versions below 1.9.2.

### Fixes

* Fix deployment notification failure in Capistrano
  | [Simon Maynard](https://github.com/snmaynard)
  | [#275](https://github.com/bugsnag/bugsnag-ruby/pull/275)

* Fix Bad Request errors generated by large payloads
  | [Simon Maynard](https://github.com/snmaynard)
  | [#276](https://github.com/bugsnag/bugsnag-ruby/pull/276)


3.0.0 (23 Dec 2015)
-----

### Enhancements

* Fix warning from usage of `before_filter` in Rails 5
  | [Scott Ringwelski](https://github.com/sgringwe)
  | [#267](https://github.com/bugsnag/bugsnag-ruby/pull/267)

* Use Rails 5-style deep parameter filtering
  | [fimmtiu](https://github.com/fimmtiu)
  | [#256](https://github.com/bugsnag/bugsnag-ruby/pull/256)

  Note: This is a backwards incompatible change, as filters containing `.` are
  now parsed as nested instead of as a single key.


2.8.13
------

### Bug Fixes

* Fix crash during heroku Rake task when an environment variable was empty
  | [#261](https://github.com/bugsnag/bugsnag-ruby/issues/261)

### Enhancements

* Various warning fixes
  | [Taylor Fausak](https://github.com/tfausak)
  | [#254](https://github.com/bugsnag/bugsnag-ruby/pull/254)
* Make the list of vendor paths configurable
  | [Jean Boussier](https://github.com/byroot)
  | [#253](https://github.com/bugsnag/bugsnag-ruby/pull/253)

2.8.12
------

-   Ensure timeout is set when configured
-   Allow on premise installations to easily send deploy notifications

2.8.11
------

-   Better handle errors in ActiveRecord transactions (thanks @arthurnn!)

2.8.10
------

-   Remove multi_json from deploy

2.8.9
-----

-   Remove dependency on `multi_json`, fall back to the `json` gem for Ruby < 1.9

2.8.8
-----

-   Pull IP address from action_dispatch.remote_ip if available

2.8.7
-----

-   Fix for old rails 3.2 not having runner defined in the railtie
-   Support for rails API
-   Added support for ca_file for dealing with SSL issues
-   Threadsafe ignore_classes
-   Add app type
-   Dont send cookies in their own tab

2.8.6
-----

-   Don't report SystemExit from `rails runner`
-   Fix for stacktrace including custom bugsnag middleware
-   Fix reporting of errors in rails-defined rake tasks

2.8.5
-----

-   Fix performance problems in cleanup_obj


2.8.4
-----

-   Automatically catch errors in `rails runner`
-   Accept meta_data from any exception that deines `bugsnag_meta_data`

2.8.3
-----

-   Delay forking the delivery thread

2.8.2
-----
-   Fix various threading issues during library initialization

2.8.1
-----
-   Exclude cookies and authorization headers by default
-   Include rails exclusion list at the right time

2.8.0
-----
-   Make meta_data available to before_notify hooks
-   Fix bug with rails param filters
-   Fix encoding error in exception message

2.7.1
-----
-   Add rake task to create a Heroku deploy hook

2.7.0
-----
-   Fix configuration of http timeouts
-   Fix configuration of http proxies
-   Remove dependency on httparty
-   Allow for symbols in rack env

2.6.1
-----
-   Fix Ruby 1.8 payload delivery bug (thanks @colin!)

2.6.0
-----
-   Collect and send snippets of source code to Bugsnag
-   Fix resque integration
-   Allow configuration of delivery method (from the default `:thread_queue` to `:synchronous`)
-   Fix parameter filtering in rails 2
-   Allow pathname in project root

2.5.1
-----
-   Collect and send HTTP headers to bugsnag to help debugging

2.5.0
-----
-   Allow access to the metadata object in before bugsnag notify callbacks
-   Dont send the rack env by default

2.4.1
------

-   Ensure filtering behaviour matches rails' for symbol filters
-   Fix Rails 4 sessions appearing in Custom tab instead of its own ([144](https://github.com/bugsnag/bugsnag-ruby/issues/144))

2.4.0
-----
-   Allow filters to be regular expressions (thanks @tamird)
-   Ensure filtering behavior matches rails' when importing filters from
    `Rails.configuration.filter_parameters`

2.3.0
-----
-   Use ssl by default (Thanks @dkubb)

2.2.2
-----
-   Add additional ignored classes
-   Check all chained exceptions on an error for ignored classes

2.2.1
-----
-   Fix occasional crash when reading rack params.
-   Don't strip files with bugsnag in the name.

2.2.0
-----
-   Move Bugsnag notifications onto a background thread.

2.1.0
-----
-   Add job detail support to delayed_job integration (thanks dtaniwaki!)

2.0.3
-----
-   Load the env in the deploy rake task if there is no api key set

2.0.2
-----
-   Fix encoding issue when ensuring utf8 string is valid

2.0.1
-----
-   Fix capistrano v3 after 2.0.0

2.0.0
-----
-   BREAKING: capistrano integration requires explicit configuration to avoid loading rails env (15x faster to notify)
-   Sidekiq 3 support
-   java.lang.Throwable support for jruby
-   Show non-serializable objects as '[Object]' instead of 'null'.
-   Fix delayed job 2.x
-   Fix rake support
-   Fix missing notifications caused by invalid utf8

1.8.8
-----
-   Prepare 'severity' feature for release

1.8.7
-----
-   Fix capistrano when `rake` is not set. #87
-   Fix capistrano when `Rails` is not loaded. #85
-   Various cleanup

1.8.6
-----
-   Proxy support in the bugsnag deploy notification rake task

1.8.5
-----
-   Capistrano3 support (for real)
-   delayed_job support

1.8.4
-----
-   Support for per-notification api keys

1.8.3
-----
-   Capistrano3 support
-   Allow `set :bugsnag_api_key, foo` in capistrano

1.8.2
-----
-   Notify all exceptions in mailman and sidekiq

1.8.1
-----
-   Fix Rails2 middleware issue that stopped automatic metadata collection

1.8.0
-----
-   Move away from Jeweler
-   Support for Exception#cause in ruby 2.1.0

1.7.0
-----
-   Allow users to configure app type
-   Send severity of error to bugsnag
-   Allo users to configure users in a structured way for search etc.

1.6.5
-----
-   Send hostname to Bugsnag

1.6.4
-----
-   Fix load order issue with Resque

1.6.3
-----
-   Deal with SSL properly for deploy notifications on ruby <2.0

1.6.2
-----
-   Notify about exceptions that occur in ActiveRecord `commit` and `rollback`
    callbacks (these are usually swallowed silently by rails)

1.6.1
-----
-   Ensure sidekiq, mailman and rake hooks respect the `ignore_classes` setting
-   Persist sidekiq and mailman meta-data through each job, so it can show up
    in manual Bugsnag.notify calls

1.6.0
-----
-   Add support for catching crashes in [mailman](https://github.com/titanous/mailman) apps
-   Automatically enable Bugsnag's resque failure backend
-   Add automatic rake integration for rails apps

1.5.3
-----
-   Deal with self-referential meta data correctly.
-   Dont load the environment when performing a deploy with capistrano.

1.5.2
-----
-   Dont send rack.request.form_vars as it is a copy of form_hash and it may contain sensitive params.

1.5.1
-----
-   Fix rake block arguments for tasks that need them.

1.5.0
-----
-   Add proxy support for http requests to Bugsnag.
-   Read the API key from the environment for Heroku users

1.4.2
-----
-   Add HTTP Referer to the request tab on rack apps

1.4.0
-----
- 	Add ignore_user_agents to ignore certain user agents
-  	Change bugsnag middleware order to have Callbacks last
- 	Allow nil values to be sent to bugsnag

1.3.8
-----
- 	Add truncated only when a field has been truncated

1.3.7
-----
- 	Fix warden bug where user id is an array of ids
- 	Filter get params from URLs as well as meta_data

1.3.6
-----
-   Filter out meta-data keys containing the word 'secret' by default

1.3.5
-----
-   Fixed bug in rake integration with ruby 1.9 hash syntax

1.3.4
-----
-   Fix nil bug in windows backtraces

1.3.3
-----
-   Support windows-style paths in backtraces
-   Fix bug with `before_bugsnag_notify` in Rails 2

1.3.2
-----
-   Notify will now build exceptions if a non-exception is passed in.

1.3.1
-----
-   Add support for Bugsnag rake integration

1.3.0
------
-   By default we notify in all release stages now
-   Return the notification in notify_or_ignore

1.2.18
------
-   Add support for bugsnag meta data in exceptions.

1.2.17
------
-   Clear the before bugsnag notify callbacks on sidekiq when a job is complete

1.2.16
------
-   Allow lambda functions in config.ignore_classes

1.2.15
------
-   Add stacktrace to internal bugsnag logging output
-   Protect against metadata not being a hash when truncation takes place

1.2.14
------
-   Add debug method, configuration option to help debug issues
-   Better protection against bad unicode strings in metadata

1.2.13
------
-   Protect against invalid unicode strings in metadata

1.2.12
------
-   Fixed minor HTTParty dependency issue

1.2.11
------
-   Send rails version with exceptions
-   Protect against nil params object when errors happen in rack

1.2.10
------
-   Added Rack HTTP method (GET, POST, etc) to request tab

1.2.9
-----
-   Fixed an issue with Warden userIds not being reported properly.

1.2.8
-----
-   Added `disable` method to Bugsnag middleware, allows you to force-disable
    built-in Bugsnag middleware.

1.2.7
-----
-   Protect against rare exception-unwrapping infinite loop
    (only in some exceptions using the `original_exception` pattern)

1.2.6
-----
-   Fix for rails 2 request data extraction
-   Deploy environment customization support (thanks coop)
-   Ensure Bugsnag rails 3 middleware runs before initializers

1.2.5
-----
-   Show a warning if no release_stage is set when delivering exceptions
-   Require resque plugin in a safer way

1.2.4
-----
-   Automatically set the release_stage in a safer way on rack/rails

1.2.3
-----
-   Re-add support for sending bugsnag notifications via resque

1.2.2
-----
-   Add rspec tests for rack middleware

1.2.1
-----
-   Fix a bug where before/after hooks were not being fired

1.2.0
-----
-   Added Bugsnag Middleware and callback, easier ways to add custom data to
    your exceptions
-   Added automatic Sidekiq integration
-   Added automatic Devise integration
-   Comprehensive rspec tests

1.1.5
-----
-   Fix minor internal version number parsing bug

1.1.4
-----
-   Move Bugsnag rack middleware later in the middleware stack, fixes
    issue where development exception may not have been delivered

1.1.3
-----
-   Fix multi_json conflict with rails 3.1
-   Make bugsnag_request_data public for easier EventMachine integration
    (thanks fblee)

1.1.2
-----
-   Fix multi_json gem dependency conflicts

1.1.1
-----
-   Capistrano deploy tracking support
-   More reliable project_root detection for non-rails rack apps
-   Support for sending test exceptions from rake (`rake bugsnag:test_exception`)

1.1.0
-----
-   First public release
