## 0.4.3 (2020-11-01)

- Added support for AWS SES

## 0.4.2 (2020-04-06)

- Added support for official SendGrid gem
- Fixed deprecation warning

## 0.4.1 (2019-10-27)

- Added Postmark support

## 0.4.0 (2019-07-15)

- Fixed error with model methods and `email_key` option
- Fixed bug with `opted_out` scope
- Dropped support for Action Mailer 4.2

## 0.3.1 (2018-04-21)

- Fixed `Secret should not be nil` error in Rails 5.2
- Gracefully handle missing email
- Added `user` option to `mailkick_unsubscribe_url`

## 0.3.0 (2018-04-20)

- Improved performance
- Fixed `Subscription not found` for Rails 5.2
- Use `references` in migration
- Use `smtp_settings[:domain]` for Mailgun
- Dropped support for Action Mailer < 4.2

## 0.2.1 (2017-10-30)

- Fixed errors with Rails 5+
- Fixed errors with the latest version of Gibbon

## 0.2.0 (2017-05-01)

- Added support for Rails 5.1

## 0.1.6 (2017-01-10)

- Fixed error with frozen strings

## 0.1.5 (2016-12-06)

- Use `safely`
- Only discover services if not manually set
- Added `mount` option

## 0.1.4 (2016-02-20)

- Use `Module#prepend` instead of `alias_method_chain`

## 0.1.3 (2015-06-29)

- Fixed issue with double escaping tokens

## 0.1.2 (2015-06-07)

- Added support for Mailgun

## 0.1.1 (2015-01-31)

- Fixed tokens with `+` in them

## 0.1.0 (2014-08-31)

- Fixed secret token for Rails 4.1

## 0.0.6 (2014-05-09)

- Rails 3 fix

## 0.0.5 (2014-05-05)

- Fixed bug with subscriptions page

## 0.0.4 (2014-05-05)

- Added `email_key` option to `mailkick_user`

## 0.0.3 (2014-05-04)

- Added support for multiple lists
- Changed `mailkick_user` method names - sorry early adopters :(

## 0.0.2 (2014-05-04)

- Added Mailchimp service
- Fixed Mandrill service
- Added `uniq` to `subscribed` scope

## 0.0.1 (2014-05-04)

- First release
