# Change log

## master (unreleased)

## 0.12.1

* Drop support for old Rubies. [#284](https://github.com/pocke/rbs_rails/pull/284)
* Make type names absolute to avoid referring to incorrect class. [#265](https://github.com/pocke/rbs_rails/pull/265)
* Avoid to create directory on initialization. [#261](https://github.com/pocke/rbs_rails/pull/261)
* Make `build_*` methods parameters optional. [#258](https://github.com/pocke/rbs_rails/pull/258)
* Skip to define rake tasks when rbs_rails is not able to load. [#251](https://github.com/pocke/rbs_rails/pull/251)

## 0.12.0

* Support RBS v3. [#246](https://github.com/pocke/rbs_rails/pull/246)
* Ignore `_scope` as enum field name. [#249](https://github.com/pocke/rbs_rails/pull/249)

## 0.11.0 (2022-03-24)

### New Features

* Add rails generator to generate rbs.rake. [#217](https://github.com/pocke/rbs_rails/pull/217)

### Bug Fixes

* Do not expose polyfil RBSs. [#218](https://github.com/pocke/rbs_rails/pull/218)

## 0.10.1 (2022-03-23)

### Bug Fixes

* Generate dependency types of relations. [#216](https://github.com/pocke/rbs_rails/pull/216)

## 0.10.0 (2022-03-18)

### New Features

* Support `has_secure_password`. [#193](https://github.com/pocke/rbs_rails/pull/193)
* Support Active Storage. [#195](https://github.com/pocke/rbs_rails/pull/195)

### Bug Fixes

* Use absolute path for class names to avoid using incorrect class. [#201](https://github.com/pocke/rbs_rails/pull/201)
* Fix NoMethodError on enum with `_default` option. [#208](https://github.com/pocke/rbs_rails/pull/208)

## 0.9.0 (2021-09-18)

### New Features

* Support delegated_type association. [#181](https://github.com/pocke/rbs_rails/pull/181)

### Bug Fixes

* Fix error on a table that doesn't have the PK. [#121](https://github.com/pocke/rbs_rails/pull/121)
* Quote variable names to avoid syntax errors. [#178](https://github.com/pocke/rbs_rails/pull/178)
* Add scope methods to `ActiveRecord_Associations_CollectionProxy`. [#182](https://github.com/pocke/rbs_rails/pull/182)
* Make `has_one` association optional. [#180](https://github.com/pocke/rbs_rails/pull/180)
* Omit some methods for polymorphic associations. [#184](https://github.com/pocke/rbs_rails/pull/184)
* Include enum methods to GeneratedRelationMethods. [#183](https://github.com/pocke/rbs_rails/pull/183)
* Include `_ActiveRecord_Relation` to `CollectionProxy`. [#189](https://github.com/pocke/rbs_rails/pull/189)

## 0.8.2 (2021-02-20)

*  Add ActiveRecord::AttributeMethods::Dirty methods [#104](https://github.com/pocke/rbs_rails/pull/104)
*  Define find method based on primary key [#105](https://github.com/pocke/rbs_rails/pull/105)

## 0.8.1 (2021-01-09)

* Skip generation RBS fro class that doesn't have table in DB. [#95](https://github.com/pocke/rbs_rails/pull/95)

## 0.8.0 (2020-12-31)

* **[BREAKING]** Move RBS files that are copied by `rbs_rails:copy_signature_files` task to [ruby/gem_rbs](https://github.com/ruby/gem_rbs) repository [#90](https://github.com/pocke/rbs_rails/pull/90)
* Allow all kinds of argument for scope [#89](https://github.com/pocke/rbs_rails/pull/89)

## 0.7.0 (2020-12-28)

* **[BREAKING]** Re-structure signature directory. [#86](https://github.com/pocke/rbs_rails/pull/86)
* Generate ActiveRecord models with namespaces and superclasses. [#87](https://github.com/pocke/rbs_rails/pull/87)
