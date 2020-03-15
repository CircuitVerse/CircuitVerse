## 2.0.0 / 2019-08-09
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.7.1...v2.0.0)

Enhancements:

* Add push notification with Action Cable - [#101](https://github.com/simukappu/activity_notification/issues/101)
* Allow use with Rails 6.0 - [#102](https://github.com/simukappu/activity_notification/issues/102)
* Add Amazon DynamoDB support using Dynamoid
* Add *ActivityNotification.config.store_with_associated_records* option
* Add test case using Mongoid orm with ActiveRecord application
* Publish demo application on Heroku

Bug Fixes:

* Fix syntax error of a default view *_default_without_grouping.html.erb*

Deprecated:

* Remove deprecated *ActivityNotification.config.table_name* option

## 1.7.1 / 2019-04-30
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.7.0...v1.7.1)

Enhancements:

* Use after_commit for tracked callbacks instead of after_create and after_update - [#99](https://github.com/simukappu/activity_notification/issues/99)

## 1.7.0 / 2018-12-09
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.6.1...v1.7.0)

Enhancements:

* Support asynchronous notification API - [#29](https://github.com/simukappu/activity_notification/issues/29)

Bug Fixes:

* Fix migration generator to specify the Rails release in generated migration files for Rails 5.x - [#96](https://github.com/simukappu/activity_notification/issues/96)

Breaking Changes:

* Change method name of *Target#notify_to* into *Target#receive_notification_of* to avoid ambiguous method name with *Notifiable#notify_to* - [#88](https://github.com/simukappu/activity_notification/issues/88)

## 1.6.1 / 2018-11-19
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.6.0...v1.6.1)

Enhancements:

* Update README.md to describe how to customize email subject - [#93](https://github.com/simukappu/activity_notification/issues/93)

Bug Fixes:

* Fix *notify_all* method to handle single notifiable target models - [#88](https://github.com/simukappu/activity_notification/issues/88)

## 1.6.0 / 2018-11-11
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.5.1...v1.6.0)

Enhancements:

* Add simple default routes with devise integration - [#64](https://github.com/simukappu/activity_notification/issues/64)
* Add *:routing_scope* option to support routes with scope - [#56](https://github.com/simukappu/activity_notification/issues/56)

Bug Fixes:

* Update *Subscription.optional_targets* into HashWithIndifferentAccess to fix subscriptions with mongoid

## 1.5.1 / 2018-08-26
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.5.0...v1.5.1)

Enhancements:

* Allow configuration of custom mailer templates directory - [#32](https://github.com/simukappu/activity_notification/pull/32)
* Make Notifiable#notifiable_path to work when it is defined in a superclass - [#45](https://github.com/simukappu/activity_notification/pull/45)

Bug Fixes:

* Fix mongoid development dependency to work with bullet - [#72](https://github.com/simukappu/activity_notification/issues/72)
* Remove duplicate scope of filtered_by_type since it is also defined in API - [#78](https://github.com/simukappu/activity_notification/pull/78)
* Fix a bug in Subscriber concern about lack of arguments - [#80](https://github.com/simukappu/activity_notification/issues/80)

## 1.5.0 / 2018-05-05
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.4.4...v1.5.0)

Enhancements:

* Allow use with Rails 5.2
* Enhancements for using the gem with i18n
  * Symbolize parameters for i18n interpolation
  * Allow pluralization in i18n translation 
  * Update render method to use plain

Bug Fixes:

* Fix a doc bug for controllers template

## 1.4.4 / 2017-11-18
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.4.3...v1.4.4)

Enhancements:

* Enable Amazon SNS optional target to use aws-sdk v3 service specific gems

Bug Fixes:

* Fix error calling #notify for callbacks in *tracked_option*
* Fix *unopened_group_member_notifier_count* and *opened_group_member_notifier_count* error when using a custom table name

## 1.4.3 / 2017-09-16
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.4.2...v1.4.3)

Enhancements:

* Add *:pass_full_options* option to *NotificationApi#notify* passing the entire options to notification targets

Bug Fixes:

* Add `{ optional: true }` for *:group* and *:notifier* when it is used with Rails 5

## 1.4.2 / 2017-07-22
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.4.1...v1.4.2)

Enhancements:

* Add function to override the subject of notification email

Bug Fixes:

* Fix a bug which ActivityNotificaion.config.mailer configuration was ignored

## 1.4.1 / 2017-05-17
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.4.0...v1.4.1)

Enhancements:

* Remove dependency on *activerecord* from gemspec

## 1.4.0 / 2017-05-10
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.3.0...v1.4.0)

Enhancements:

* Allow use with Rails 5.1
* Allow mongoid models as *Target* and *Notifiable* models
* Add functions for automatic tracked notifications
* Enable *render_notification_of* view helper method to use *:as_latest_group_member* option

Bug Fixes:

* Fix illegal ActiveRecord query in *Notification#uniq_keys* and *Subscription#uniq_keys* for MySQL and PostgreSQL database

Breaking Changes:

* Update type of polymorphic id field in *Notification* and *Subscription* models from Integer to String

## 1.3.0 / 2017-04-07
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.2.1...v1.3.0)

Enhancements:

* Suport Mongoid ORM to store *Notification* and *Subscription* records
  * Separate *Notification* and *Subscription* models into ORMs and make them load from ORM selector
  * Update query logic in *Notification* and *Subscription* models for Mongoid
* Make *:dependent_notifications* option in *acts_as_notifiable* separate into each target configuration
* Add *overriding_notification_template_key* to *Notifiable* model for *Renderable*
* Enable Devise integration to use models with single table inheritance

## 1.2.1 / 2017-01-06
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.2.0...v1.2.1)

Enhancements:

* Support default Slack optional target with *slack-notifier* 2.0.0

Breaking Changes:

* Rename *:slack_name* initializing parameter and template parameter of default Slack optional target to *:target_username*

## 1.2.0 / 2017-01-06
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.1.0...v1.2.0)

Enhancements:

* Add optional target function
  * Optional target development framework
  * Subscription management for optional targets
  * Amazon SNS client as default optional target implementation
  * Slack client as default optional target implementation
* Add *:restrict_with_+* and *:update_group_and_+* options to *:dependent_notifications* of *acts_as_notifiable*

## 1.1.0 / 2016-12-18
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.0.2...v1.1.0)

Enhancements:

* Add subscription management framework
  * Subscription management model and API
  * Default subscription controllers, routing and views
  * Add *Subscriber* role configuration to *Target* role
* Add *:as_latest_group_member* option to batch mailer API
* Add *:group_expiry_delay* option to notification API

Bug Fixes:

* Fix unserializable error in *Target#send_batch_unopened_notification_email* since unnecessary options are passed to mailer

Breaking Changes:

* Remove *notifiable_type* from the argument of overridden method or configured lambda function with *:batch_email_allowed* option in *acts_as_target* role

## 1.0.2 / 2016-11-14
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.0.1...v1.0.2)

Bug Fixes:

* Fix migration and notification generator's path

## 1.0.1 / 2016-11-05
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v1.0.0...v1.0.1)

Enhancements:

* Add function to send batch email notification
  * Batch mailer API
  * Default batch notification email templates
  * *Target* role configuration for batch email notification
* Improve target API
  * Add *:reverse*, *:with_group_members*, *:as_latest_group_member* and *:custom_filter* options to API loading notification index
  * Add methods to get notifications for specified target type grouped by targets like *Target#notification_index_map*
* Arrange default notification email view templates

Breaking Changes:

* Use instance variable `@notification.notifiable` instead of `@notifiable` in notification email templates

## 1.0.0 / 2016-10-06
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v0.0.10...v1.0.0)

Enhancements:

* Improve notification API
  * Add methods to count distinct group members or notifiers like *group_member_notifier_count*
  * Update *send_later* argument of *send_notification_email* method to options hash argument
* Improve target API
  * Update *notification_index* API to automatically load opened notifications with unopend notifications
* Improve acts_as roles
  * Add *acts_as_group* role
  * Add *printable_name* configuration for all roles
  * Add *:dependent_notifications* option to *acts_as_notifiable* to make handle notifications with deleted notifiables
* Arrange default notification view templates
* Arrange bundled test application
* Make default rails version 5.0 and update gem dependency

Breaking Changes:

* Rename `config.opened_limit` configuration parameter to `config.opened_index_limit`
  * http://github.com/simukappu/activity_notification/commit/591e53cd8977220f819c11cd702503fc72dd1fd1

## 0.0.10 / 2016-09-11
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v0.0.9...v0.0.10)

Enhancements:

* Improve controller action and notification API
  * Add filter options to *NotificationsController#open_all* action and *Target#open_all_of* method
* Add source documentation with YARD
* Support rails 5.0 and update gem dependency

Bug Fixes:

* Fix *Notification#notifiable_path* method to be called with key
* Add including *PolymorphicHelpers* statement to *seed.rb* in test application to resolve String extention

## 0.0.9 / 2016-08-19
[Full Changelog](http://github.com/simukappu/activity_notification/compare/v0.0.8...v0.0.9)

Enhancements:

* Improve acts_as roles
  * Enable models to be configured by acts_as role without including statement
  * Disable email notification as default and add email configurations to acts_as roles
  * Remove *:skip_email* option from *acts_as_target*
* Update *Renderable#text* method to use `"#{key}.text"` field in i18n properties
  
Bug Fixes:

* Fix wrong method name of *Notification#notifiable_path*

## 0.0.8 / 2016-07-31
* First release
