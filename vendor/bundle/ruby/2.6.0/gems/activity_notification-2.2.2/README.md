# ActivityNotification

[![Build Status](https://travis-ci.com/simukappu/activity_notification.svg?branch=master)](https://travis-ci.com/simukappu/activity_notification)
[![Coverage Status](https://coveralls.io/repos/github/simukappu/activity_notification/badge.svg?branch=master)](https://coveralls.io/github/simukappu/activity_notification?branch=master)
[![Dependency](https://img.shields.io/depfu/simukappu/activity_notification.svg)](https://depfu.com/repos/simukappu/activity_notification)
[![Inline docs](http://inch-ci.org/github/simukappu/activity_notification.svg?branch=master)](http://inch-ci.org/github/simukappu/activity_notification)
[![Gem Version](https://badge.fury.io/rb/activity_notification.svg)](https://rubygems.org/gems/activity_notification)
[![Gem Downloads](https://img.shields.io/gem/dt/activity_notification.svg)](https://rubygems.org/gems/activity_notification)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](MIT-LICENSE)

*activity_notification* provides integrated user activity notifications for [Ruby on Rails](https://rubyonrails.org). You can easily use it to configure multiple notification targets and make activity notifications with notifiable models, like adding comments, responding etc.

*activity_notification* supports Rails 5.0+ with [ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html), [Mongoid](https://mongoid.org) and [Dynamoid](https://github.com/Dynamoid/dynamoid) ORM. It is tested for [MySQL](https://www.mysql.com), [PostgreSQL](https://www.postgresql.org), [SQLite3](https://www.sqlite.org) with ActiveRecord, [MongoDB](https://www.mongodb.com) with Mongoid and [Amazon DynamoDB](https://aws.amazon.com/dynamodb) with Dynamoid. If you are using Rails 4.2, use [v2.1.4](https://rubygems.org/gems/activity_notification/versions/2.1.4) or older version of *activity_notification*.


## About

*activity_notification* provides following functions:
* Notification API for your Rails application (creating and managing notifications, query for notifications)
* Notification models (stored with ActiveRecord, Mongoid or Dynamoid ORM)
* Notification controllers (managing open/unopen of notifications, providing link to notifiable activity page)
* Notification views (presentation of notifications)
* Automatic tracked notifications (generating notifications along with the lifecycle of notifiable models)
* Grouping notifications (grouping like *"Kevin and 7 other users posted comments to this article"*)
* Email notification
* Batch email notification (event driven or periodical email notification, daily or weekly etc)
* Push notification with [Action Cable](https://guides.rubyonrails.org/action_cable_overview.html)
* Subscription management (subscribing and unsubscribing for each target and notification type)
* REST API backend and [OpenAPI Specification](https://github.com/OAI/OpenAPI-Specification)
* Integration with [Devise](https://github.com/plataformatec/devise) authentication
* Activity notifications stream integrated into cloud computing using [Amazon DynamoDB Streams](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html)
* Optional notification targets (Configurable optional notification targets like [Amazon SNS](https://aws.amazon.com/sns), [Slack](https://slack.com), SMS and so on)

### Online Demo

You can see an actual application using this gem here:
* **https://activity-notification-example.herokuapp.com/**

Login as the following test users to experience user activity notifications:

| Email | Password | Admin? |
|:---:|:---:|:---:|
| ichiro@example.com  | changeit | Yes |
| stephen@example.com | changeit |     |
| klay@example.com    | changeit |     |
| kevin@example.com   | changeit |     |

The deployed demo application is included in this gem's source code as a test application here: *[/spec/rails_app](/spec/rails_app/)*

### Notification index and plugin notifications

<kbd>![plugin-notifications-image](https://raw.githubusercontent.com/simukappu/activity_notification/images/activity_notification_plugin_focus_with_subscription.png)</kbd>

*activity_notification* deeply uses [PublicActivity](https://github.com/pokonski/public_activity) as reference in presentation layer.

### Subscription management of notifications

<kbd>![subscription-management-image](https://raw.githubusercontent.com/simukappu/activity_notification/images/activity_notification_subscription_management_with_optional_targets.png)</kbd>

### Amazon SNS as optional notification target

<kbd>![optional-target-amazon-sns-email-image](https://raw.githubusercontent.com/simukappu/activity_notification/images/activity_notification_optional_target_amazon_sns.png)</kbd>

### Slack as optional notification target

<kbd>![optional-target-slack-image](https://raw.githubusercontent.com/simukappu/activity_notification/images/activity_notification_optional_target_slack.png)</kbd>

### Public REST API reference as OpenAPI Specification

REST API reference as OpenAPI Specification is published in SwaggerHub here:
* **https://app.swaggerhub.com/apis-docs/simukappu/activity-notification/**

You can see sample single page application using [Vue.js](https://vuejs.org) as a part of example Rails application here:
* **https://activity-notification-example.herokuapp.com/spa/**

This sample application works with *activity_notification* REST API backend.


## Table of Contents

- [About](#about)
  - [Online Demo](#online-demo)
  - [Public REST API reference as OpenAPI Specification](#public-rest-apu-reference-as-openapi-specification)
- [Getting Started](#getting-started)
- [Setup](/docs/Setup.md#Setup)
  - [Gem installation](/docs/Setup.md#gem-installation)
  - [Database setup](/docs/Setup.md#database-setup)
    - [Using ActiveRecord ORM](/docs/Setup.md#using-activerecord-orm)
    - [Using Mongoid ORM](/docs/Setup.md#using-mongoid-orm)
    - [Using Dynamoid ORM](/docs/Setup.md#using-dynamoid-orm)
      - [Integration with DynamoDB Streams](/docs/Setup.md#integration-with-dynamodb-streams)
  - [Configuring models](/docs/Setup.md#configuring-models)
    - [Configuring target models](/docs/Setup.md#configuring-target-models)
    - [Configuring notifiable models](/docs/Setup.md#configuring-notifiable-models)
      - [Advanced notifiable path](/docs/Setup.md#advanced-notifiable-path)
  - [Configuring views](/docs/Setup.md#configuring-views)
  - [Configuring routes](/docs/Setup.md#configuring-routes)
    - [Routes with scope](/docs/Setup.md#routes-with-scope)
    - [Routes as REST API backend](/docs/Setup.md#routes-as-rest-api-backend)
  - [Creating notifications](/docs/Setup.md#creating-notifications)
    - [Notification API](/docs/Setup.md#notification-api)
    - [Asynchronous notification API with ActiveJob](/docs/Setup.md#asynchronous-notification-api-with-activejob)
    - [Automatic tracked notifications](/docs/Setup.md#automatic-tracked-notifications)
  - [Displaying notifications](/docs/Setup.md#displaying-notifications)
    - [Preparing target notifications](/docs/Setup.md#preparing-target-notifications)
    - [Rendering notifications](/docs/Setup.md#rendering-notifications)
    - [Notification views](/docs/Setup.md#notification-views)
    - [i18n for notifications](/docs/Setup.md#i18n-for-notifications)
  - [Customizing controllers (optional)](/docs/Setup.md#customizing-controllers-optional)
- [Functions](/docs/Functions.md#Functions)
  - [Email notification](/docs/Functions.md#email-notification)
    - [Mailer setup](/docs/Functions.md#mailer-setup)
    - [Sender configuration](/docs/Functions.md#sender-configuration)
    - [Email templates](/docs/Functions.md#email-templates)
    - [Email subject](/docs/Functions.md#email-subject)
    - [Other header fields](/docs/Functions.md#other-header-fields)
    - [i18n for email](/docs/Functions.md#i18n-for-email)
  - [Batch email notification](/docs/Functions.md#batch-email-notification)
    - [Batch mailer setup](/docs/Functions.md#batch-mailer-setup)
    - [Batch sender configuration](/docs/Functions.md#batch-sender-configuration)
    - [Batch email templates](/docs/Functions.md#batch-email-templates)
    - [Batch email subject](/docs/Functions.md#batch-email-subject)
    - [i18n for batch email](/docs/Functions.md#i18n-for-batch-email)
  - [Grouping notifications](/docs/Functions.md#grouping-notifications)
  - [Subscription management](/docs/Functions.md#subscription-management)
    - [Configuring subscriptions](/docs/Functions.md#configuring-subscriptions)
    - [Managing subscriptions](/docs/Functions.md#managing-subscriptions)
    - [Customizing subscriptions](/docs/Functions.md#customizing-subscriptions)
  - [REST API backend](/docs/Functions.md#rest-api-backend)
    - [Configuring REST API backend](/docs/Functions.md#configuring-rest-api-backend)
    - [API reference as OpenAPI Specification](/docs/Functions.md#api-reference-as-openapi-specification)
  - [Integration with Devise](/docs/Functions.md#integration-with-devise)
    - [Configuring integration with Devise authentication](/docs/Functions.md#configuring-integration-with-devise-authentication)
    - [Using different model as target](/docs/Functions.md#using-different-model-as-target)
    - [Configuring simple default routes](/docs/Functions.md#configuring-simple-default-routes)
    - [REST API backend with Devise Token Auth](/docs/Functions.md#rest-api-backend-with-devise-token-auth)
  - [Push notification with Action Cable](/docs/Functions.md#push-notification-with-action-cable)
    - [Enabling broadcasting notifications to channels](/docs/Functions.md#enabling-broadcasting-notifications-to-channels)
    - [Subscribing notifications from channels](/docs/Functions.md#subscribing-notifications-from-channels)
    - [Subscribing notifications with Devise authentication](/docs/Functions.md#subscribing-notifications-with-devise-authentication)
    - [Subscribing notifications API with Devise Token Auth](/docs/Functions.md#subscribing-notifications-api-with-devise-token-auth)
    - [Subscription management of Action Cable channels](/docs/Functions.md#subscription-management-of-action-cable-channels)
  - [Optional notification targets](/docs/Functions.md#optional-notification-targets)
    - [Configuring optional targets](/docs/Functions.md#configuring-optional-targets)
    - [Customizing message format](/docs/Functions.md#customizing-message-format)
    - [Action Cable channels as optional target](/docs/Functions.md#action-cable-channels-as-optional-target)
    - [Amazon SNS as optional target](/docs/Functions.md#amazon-sns-as-optional-target)
    - [Slack as optional target](/docs/Functions.md#slack-as-optional-target)
    - [Developing custom optional targets](/docs/Functions.md#developing-custom-optional-targets)
    - [Subscription management of optional targets](/docs/Functions.md#subscription-management-of-optional-targets)
- [Testing](/docs/Testing.md#Testing)
  - [Testing your application](/docs/Testing.md#testing-your-application)
  - [Testing gem alone](/docs/Testing.md#testing-gem-alone)
- [Documentation](#documentation)
- [Common Examples](#common-examples)
- [Contributing](#contributing)
- [License](#license)


## Getting Started

This getting started shows easy setup description of *activity_notification*. See [Setup](/docs/Setup.md#Setup) for more details.

### Gem installation

You can install *activity_notification* as you would any other gem:

```console
$ gem install activity_notification
```
or in your Gemfile:

```ruby
gem 'activity_notification'
```

After you install *activity_notification* and add it to your Gemfile, you need to run the generator:

```console
$ bin/rails generate activity_notification:install
```

The generator will install an initializer which describes all configuration options of *activity_notification*.

### Database setup

When you use *activity_notification* with ActiveRecord ORM as default configuration,
create migration for notifications and migrate the database in your Rails project:

```console
$ bin/rails generate activity_notification:migration
$ bin/rake db:migrate
```

See [Database setup](/docs/Setup.md#database-setup) for other ORMs.

### Configuring models

Configure your target model (e.g. *app/models/user.rb*).
Add **acts_as_target** configuration to your target model to get notifications.

```ruby
class User < ActiveRecord::Base
  acts_as_target
end
```

Then, configure your notifiable model (e.g. *app/models/comment.rb*).
Add **acts_as_notifiable** configuration to your notifiable model representing activity to notify for each of your target model.
You have to define notification targets for all notifications from this notifiable model by *:targets* option. Other configurations are optional. *:notifiable_path* option is a path to move when the notification is opened by the target user.

```ruby
class Article < ActiveRecord::Base
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :commented_users, through: :comments, source: :user
end

class Comment < ActiveRecord::Base
  belongs_to :article
  belongs_to :user

  acts_as_notifiable :users,
    targets: ->(comment, key) {
      ([comment.article.user] + comment.article.reload.commented_users.to_a - [comment.user]).uniq
    },
    notifiable_path: :article_notifiable_path

  def article_notifiable_path
    article_path(article)
  end
end
```

See [Configuring models](/docs/Setup.md#configuring-models) for more details.

### Configuring views

*activity_notification* provides view templates to customize your notification views.
See [Configuring views](/docs/Setup.md#configuring-views) for more details.

### Configuring routes

*activity_notification* also provides routing helper for notifications. Add **notify_to** method to *config/routes.rb* for the target (e.g. *:users*):

```ruby
Rails.application.routes.draw do
  notify_to :users
end
```

See [Configuring routes](/docs/Setup.md#configuring-routes) for more details.

You can also configure *activity_notification* routes as REST API backend with *api_mode* option like this:

```ruby
Rails.application.routes.draw do
  scope :api do
    scope :"v2" do
      notify_to :users, api_mode: true
    end
  end
end
```

See [Routes as REST API backend](/docs/Setup.md#configuring-routes) and [REST API backend](/docs/Functions.md#rest-api-backend) for more details.

### Creating notifications

You can trigger notifications by setting all your required parameters and triggering **notify** on the notifiable model, like this:

```ruby
@comment.notify :users, key: "comment.reply"
```

The first argument is the plural symbol name of your target model, which is configured in notifiable model by *acts_as_notifiable*.
The new instances of **ActivityNotification::Notification** model will be generated for the specified targets.

See [Creating notifications](/docs/Setup.md#creating-notifications) for more details.

### Displaying notifications

*activity_notification* also provides notification views. You can prepare target notifications, render them in your controller, and show them provided or custom notification views.

See [Displaying notifications](/docs/Setup.md#displaying-notifications) for more details.

### Run example Rails application

Test module includes example Rails application in *[spec/rails_app](/spec/rails_app)*.
Pull git repository and you can run the example application as common Rails application.

```console
$ git pull https://github.com/simukappu/activity_notification.git
$ cd activity_notification
$ bundle install —path vendor/bundle
$ cd spec/rails_app
$ bin/rake db:migrate
$ bin/rake db:seed
$ bin/rails server
```
Then, you can access <http://localhost:3000> for the example application.


## Setup

See [Setup](/docs/Setup.md#Setup).


## Functions

See [Functions](/docs/Functions.md#Functions).


## Testing

See [Testing](/docs/Testing.md#Testing).


## Documentation

See [API Reference](http://www.rubydoc.info/github/simukappu/activity_notification/index) for more details.

RubyDoc.info does not support parsing methods in *included* and *class_methods* of *ActiveSupport::Concern* currently.
To read complete documents, please generate YARD documents on your local environment:
```console
$ git pull https://github.com/simukappu/activity_notification.git
$ cd activity_notification
$ bundle install —path vendor/bundle
$ bundle exec yard doc
$ bundle exec yard server
```
Then you can see the documents at <http://localhost:8808/docs/index>.


## Common Examples

See example Rails application in *[/spec/rails_app](/spec/rails_app)*.

You can also try this example Rails application as Online Demo here:
* **https://activity-notification-example.herokuapp.com/**

You can login as test users to experience user activity notifications. For more details, see [Online Demo](#online-demo).


## Contributing

We encourage you to contribute to *activity_notification*!
Please check out the [Contributing to *activity_notification* guide](/docs/CONTRIBUTING.md#how-to-contribute-to-activity_notification) for guidelines about how to proceed.

Everyone interacting in *activity_notification* codebases, issue trackers, and pull requests is expected to follow the *activity_notification* [Code of Conduct](/docs/CODE_OF_CONDUCT.md#contributor-covenant-code-of-conduct).

We appreciate any of your contribution!


## License

*activity_notification* project rocks and uses [MIT License](MIT-LICENSE).
