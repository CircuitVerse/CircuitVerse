2.0.1 (2020-11-16)
------------------

* Issue - Expose `:config` in `RackMiddleware` and `:config_file` in `Configuration`.

* Issue - V2 of this release was still loading SDK V1 credential keys. This removes support for client options specified in YAML configuration (behavior change). Instead, construct `Aws::DynamoDB::Client` and use the `dynamo_db_client` option.

2.0.0 (2020-11-11)
------------------

* Remove Rails support (moved to the `aws-sdk-rails` gem).

* Use V3 of Ruby SDK

* Fix a `dynamo_db.scan()` incompatibility from the V1 -> V2 upgrade in the garbage collector.

1.0.0 (2017-08-14)
------------------

* Use V2 of Ruby SDK (no history)


0.5.1 (2015-08-26)
------------------

* Bug Fix (no history)

0.5.0 (2013-08-27)
------------------

* Initial Release (no history)
