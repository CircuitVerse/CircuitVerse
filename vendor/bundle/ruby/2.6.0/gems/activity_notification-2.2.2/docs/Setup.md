## Setup

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
It also generates a i18n based translation file which we can configure the presentation of notifications.

### Database setup

#### Using ActiveRecord ORM

When you use *activity_notification* with ActiveRecord ORM as default configuration,
create migration for notifications and migrate the database in your Rails project:

```console
$ bin/rails generate activity_notification:migration
$ bin/rake db:migrate
```

If you are using a different table name from *"notifications"*, change the settings in your *config/initializers/activity_notification.rb* file, e.g., if you're using the table name *"activity_notifications"* instead of the default *"notifications"*:

```ruby
config.notification_table_name = "activity_notifications"
```

The same can be done for the subscription table name, e.g., if you're using the table name *"notifications_subscriptions"* instead of the default *"subscriptions"*:

```ruby
config.subscription_table_name = "notifications_subscriptions"
```

#### Using Mongoid ORM

When you use *activity_notification* with [Mongoid](http://mongoid.org) ORM, set **AN_ORM** environment variable to **mongoid**:

```console
$ export AN_ORM=mongoid
```

You can also configure ORM in initializer **activity_notification.rb**:

```ruby
config.orm = :mongoid
```

You need to configure Mongoid in your Rails application for your MongoDB environment. Then, your notifications and subscriptions will be stored in your MongoDB.

#### Using Dynamoid ORM

Currently, *activity_notification* only works with Dynamoid 3.1.0.

```ruby
gem 'dynamoid', '3.1.0'
```

When you use *activity_notification* with [Dynamoid](https://github.com/Dynamoid/dynamoid) ORM, set **AN_ORM** environment variable to **dynamoid**:

```console
$ export AN_ORM=dynamoid
```

You can also configure ORM in initializer **activity_notification.rb**:

```ruby
config.orm = :dynamoid
```

You need to configure Dynamoid in your Rails application for your Amazon DynamoDB environment.
Then, you can use this rake task to create DynamoDB tables used by *activity_notification* with Dynamoid:

```console
$ bin/rake activity_notification:create_dynamodb_tables
```

After these configurations, your notifications and subscriptions will be stored in your Amazon DynamoDB.

Note: Amazon DynamoDB integration using Dynamoid ORM is only supported with Rails 5.0+.

##### Integration with DynamoDB Streams

You can capture *activity_notification*'s table activity with [DynamoDB Streams](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html).
Using DynamoDB Streams, activity notifications in your Rails application will be integrated into cloud computing and available as event stream processed by [DynamoDB Streams Kinesis Adapter](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.KCLAdapter.html) or [AWS Lambda](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.Lambda.html).

When you consume your activity notifications from DynamoDB Streams, sometimes you need to process notification records with associated target, notifiable or notifier record which is stored in database of your Rails application.
In such cases, you can use **store_with_associated_records** option in initializer **activity_notification.rb**:

```ruby
config.store_with_associated_records = true
```

When **store_with_associated_records** is set to *false* as default, *activity_notification* stores notificaion records with association like this:

```json
{
  "id": {
    "S": "f05756ef-661e-4ef5-9e99-5af51243125c"
  },
  "target_key": {
    "S": "User#1"
  },
  "notifiable_key": {
    "S": "Comment#2"
  },
  "key": {
    "S": "comment.default"
  },
  "group_key": {
    "S": "Article#1"
  },
  "notifier_key": {
    "S": "User#2"
  },
  "created_at": {
    "S": "2020-03-08T08:22:53+00:00"
  },
  "updated_at": {
    "S": "2020-03-08T08:22:53+00:00"
  },
  "parameters": {
      "M": {}
  }
}
```

When you set **store_with_associated_records** to *true*, *activity_notification* stores notificaion records including associated target, notifiable, notifier and several instance methods like this:

```json
{
  "id": {
    "S": "f05756ef-661e-4ef5-9e99-5af51243125c"
  },
  "target_key": {
    "S": "User#1"
  },
  "notifiable_key": {
    "S": "Comment#2"
  },
  "key": {
    "S": "comment.default"
  },
  "group_key": {
    "S": "Article#1"
  },
  "notifier_key": {
    "S": "User#2"
  },
  "created_at": {
    "S": "2020-03-08T08:22:53+00:00"
  },
  "updated_at": {
    "S": "2020-03-08T08:22:53+00:00"
  },
  "parameters": {
      "M": {}
  },
  "stored_target": {
    "M": {
      "id": {
          "N": "1"
      },
      "email": {
          "S": "ichiro@example.com"
      },
      "name": {
        "S": "Ichiro"
      },
      "created_at": {
        "S": "2020-03-08T08:22:23.451Z"
      },
      "updated_at": {
        "S": "2020-03-08T08:22:23.451Z"
      },
      // { ... },
      "printable_type": {
          "S": "User"
      },
      "printable_target_name": {
          "S": "Ichiro"
      },
    }
  },
  "stored_notifiable": {
    "M": {
      "id": {
          "N": "2"
      },
      "user_id": {
          "N": "2"
      },
      "article_id": {
          "N": "1"
      },
      "body": {
          "S": "This is the first Stephen's comment to Ichiro's article."
      },
      "created_at": {
          "S": "2020-03-08T08:22:47.683Z"
      },
      "updated_at": {
          "S": "2020-03-08T08:22:47.683Z"
      },
      "printable_type": {
          "S": "Comment"
      }
    }
  },
  "stored_notifier": {
    "M": {
      "id": {
          "N": "2"
      },
      "email": {
          "S": "stephen@example.com"
      },
      "name": {
          "S": "Stephen"
      },
      "created_at": {
          "S": "2020-03-08T08:22:23.573Z"
      },
      "updated_at": {
        "S": "2020-03-08T08:22:23.573Z"
      },
      // { ... },
      "printable_type": {
        "S": "User"
      },
      "printable_notifier_name": {
          "S": "Stephen"
      }
    }
  },
  "stored_group": {
    "M": {
      "id": {
        "N": "1"
      },
      "user_id": {
        "N": "1"
      },
      "title": {
        "S": "Ichiro's first article"
      },
      "body": {
        "S": "This is the first Ichiro's article. Please read it!"
      },
      "created_at": {
        "S": "2020-03-08T08:22:23.952Z"
      },
      "updated_at": {
        "S": "2020-03-08T08:22:23.952Z"
      },
      "printable_type": {
        "S": "Article"
      },
      "printable_group_name": {
        "S": "article \"Ichiro's first article\""
      }
    }
  },
  "stored_notifiable_path": {
    "S": "/articles/1"
  },
  "stored_printable_notifiable_name": {
    "S": "comment \"This is the first Stephen's comment to Ichiro's article.\""
  },
  "stored_group_member_notifier_count": {
    "N": "2"
  },
  "stored_group_notification_count": {
    "N": "3"
  },
  "stored_group_members": {
    "L": [
      // { ... }, { ... }, ...
    ]
  }
}
```

Then, you can process notification records with associated records in your DynamoDB Streams.

Note: This **store_with_associated_records** option can be set true only when you use mongoid or dynamoid ORM.

### Configuring models

#### Configuring target models

Configure your target model (e.g. *app/models/user.rb*).
Add **acts_as_target** configuration to your target model to get notifications.

##### Target as an ActiveRecord model

```ruby
class User < ActiveRecord::Base
  # acts_as_target configures your model as ActivityNotification::Target
  # with parameters as value or custom methods defined in your model as lambda or symbol.
  # This is an example without any options (default configuration) as the target.
  acts_as_target
end
```

##### Target as a Mongoid model

```ruby
require 'mongoid'
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  # You need include ActivityNotification::Models except models which extend ActiveRecord::Base
  include ActivityNotification::Models
  acts_as_target
end
```

*Note*: *acts_as_notification_target* is an alias for *acts_as_target* and does the same.

#### Configuring notifiable models

Configure your notifiable model (e.g. *app/models/comment.rb*).
Add **acts_as_notifiable** configuration to your notifiable model representing activity to notify for each of your target model.
You have to define notification targets for all notifications from this notifiable model by *:targets* option. Other configurations are optional. *:notifiable_path* option is a path to move when the notification is opened by the target user.

##### Notifiable as an ActiveRecord model

```ruby
class Article < ActiveRecord::Base
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :commented_users, through: :comments, source: :user
end

class Comment < ActiveRecord::Base
  belongs_to :article
  belongs_to :user

  # acts_as_notifiable configures your model as ActivityNotification::Notifiable
  # with parameters as value or custom methods defined in your model as lambda or symbol.
  # The first argument is the plural symbol name of your target model.
  acts_as_notifiable :users,
    # Notification targets as :targets is a necessary option
    # Set to notify to author and users commented to the article, except comment owner self
    targets: ->(comment, key) {
      ([comment.article.user] + comment.article.commented_users.to_a - [comment.user]).uniq
    },
    # Path to move when the notification is opened by the target user
    # This is an optional configuration since activity_notification uses polymorphic_path as default
    notifiable_path: :article_notifiable_path

  def article_notifiable_path
    article_path(article)
  end
end
```

##### Notifiable as a Mongoid model

```ruby
require 'mongoid'
class Article
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  has_many :comments, dependent: :destroy

  def commented_users
    User.where(:id.in => comments.pluck(:user_id))
  end
end

require 'mongoid'
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  # You need include ActivityNotification::Models except models which extend ActiveRecord::Base
  include ActivityNotification::Models
  acts_as_notifiable :users,
    targets: ->(comment, key) {
      ([comment.article.user] + comment.article.commented_users.to_a - [comment.user]).uniq
    },
    notifiable_path: :article_notifiable_path

  def article_notifiable_path
    article_path(article)
  end
end
```

##### Advanced notifiable path

Sometimes it might be necessary to provide extra information in the *notifiable_path*. In those cases, passing a lambda function to the *notifiable_path* will give you the notifiable object and the notifiable key to play around with:

```ruby
acts_as_notifiable :users,
  targets: ->(comment, key) {
    ([comment.article.user] + comment.article.commented_users.to_a - [comment.user]).uniq
  },
  notifiable_path: ->(comment, key) { "#{comment.article_notifiable_path}##{key}" }
```

This will attach the key of the notification to the notifiable path.

### Configuring views

*activity_notification* provides view templates to customize your notification views. The view generator can generate default views for all targets.

```console
$ bin/rails generate activity_notification:views
```

If you have multiple target models in your application, such as *User* and *Admin*, you will be able to have views based on the target like *notifications/users/index* and *notifications/admins/index*. If no view is found for the target, *activity_notification* will use the default view at *notifications/default/index*. You can also use the generator to generate views for the specified target:

```console
$ bin/rails generate activity_notification:views users
```

If you would like to generate only a few sets of views, like the ones for the *notifications* (for notification views) and *mailer* (for notification email views),
you can pass a list of modules to the generator with the *-v* flag.

```console
$ bin/rails generate activity_notification:views -v notifications
```

### Configuring routes

*activity_notification* also provides routing helper for notifications. Add **notify_to** method to *config/routes.rb* for the target (e.g. *:users*):

```ruby
Rails.application.routes.draw do
  notify_to :users
end
```

Then, you can access several pages like */users/1/notifications* and manage open/unopen of notifications using *[ActivityNotification::NotificationsController](/app/controllers/activity_notification/notifications_controller.rb)*.
If you use Devise integration and you want to configure simple default routes for authenticated users, see [Configuring simple default routes](#configuring-simple-default-routes).

#### Routes with namespaced model

It is possible to configure a target model as a submodule, e.g. if your target is `Entity::User`,
however by default the **ActivityNotification** controllers will be placed under the same namespace,
so it is mandatory to explicitly call the controllers this way

```ruby
Rails.application.routes.draw do
  notify_to :users, controller: '/activity_notification/notifications', target_type: 'entity/users'
end
```

This will generate the necessary routes for the `Entity::User` target with parameters `:user_id`

#### Routes with scope

You can also configure *activity_notification* routes with scope like this:

```ruby
Rails.application.routes.draw do
  scope :myscope, as: :myscope do
    notify_to :users, routing_scope: :myscope
  end
end
```

Then, pages are shown as */myscope/users/1/notifications*.

#### Routes as REST API backend

You can configure *activity_notification* routes as REST API backend with *api_mode* option like this:

```ruby
Rails.application.routes.draw do
  scope :api do
    scope :"v2" do
      notify_to :users, api_mode: true
    end
  end
end
```

Then, you can call *activity_notification* REST API as */api/v2/notifications* from your frontend application. See [REST API backend](#rest-api-backend) for more details.

### Creating notifications

#### Notification API

You can trigger notifications by setting all your required parameters and triggering **notify** on the notifiable model, like this:

```ruby
@comment.notify :users, key: "comment.reply"
```

Or, you can call public API as **ActivityNotification::Notification.notify**

```ruby
ActivityNotification::Notification.notify :users, @comment, key: "comment.reply"
```

The first argument is the plural symbol name of your target model, which is configured in notifiable model by *acts_as_notifiable*.
The new instances of **ActivityNotification::Notification** model will be generated for the specified targets.

*Hint*: *:key* is a option. Default key `#{notifiable_type}.default` which means *comment.default* will be used without specified key.
You can override it by *Notifiable#default_notification_key*.

#### Asynchronous notification API with ActiveJob

Using Notification API with default configurations, the notifications will be generated synchronously. *activity_notification* also supports **asynchronous notification API** with ActiveJob to improve application performance. You can use **notify_later** method on the notifiable model, like this:

```ruby
@comment.notify_later :users, key: "comment.reply"
```

You can also use *:notify_later* option in *notify* method. This is the same operation as calling *notify_later* method.

```ruby
@comment.notify :users, key: "comment.reply", notify_later: true
```

*Note*: *notify_now* is an alias for *notify* and does the same.

When you use asynchronous notification API, you should setup ActiveJob with background queuing service such as Sidekiq.
You can set *config.active_job_queue* in your initializer to specify a queue name *activity_notification* will use.
The default queue name is *:activity_notification*.

```ruby
# Configure ActiveJob queue name for delayed notifications.
config.active_job_queue = :my_notification_queue
```

#### Automatic tracked notifications

You can also generate automatic tracked notifications by **:tracked** option in *acts_as_notifiable*.
*:tracked* option adds required callbacks to generate notifications for creation and update of the notifiable model.
Set true to *:tracked* option to generate all tracked notifications, like this:

```ruby
class Comment < ActiveRecord::Base
  acts_as_notifiable :users,
    targets: ->(comment, key) {
      ([comment.article.user] + comment.article.commented_users.to_a - [comment.user]).uniq
    },
    # Set true to :tracked option to generate automatic tracked notifications.
    # It adds required callbacks to generate notifications for creation and update of the notifiable model.
    tracked: true
end
```

Or, set *:only* or *:except* option to generate specified tracked notifications, like this:

```ruby
class Comment < ActiveRecord::Base
  acts_as_notifiable :users,
    targets: ->(comment, key) {
      ([comment.article.user] + comment.article.commented_users.to_a - [comment.user]).uniq
    },
    # Set { only: [:create] } to :tracked option to generate tracked notifications for creation only.
    # It adds required callbacks to generate notifications for creation of the notifiable model.
    tracked: { only: [:create] }
end
```

```ruby
class Comment < ActiveRecord::Base
  acts_as_notifiable :users,
    targets: ->(comment, key) {
      ([comment.article.user] + comment.article.commented_users.to_a - [comment.user]).uniq
    },
    # Set { except: [:update] } to :tracked option to generate tracked notifications except update (creation only).
    # It adds required callbacks to generate notifications for creation of the notifiable model.
    tracked: { except: [:update], key: 'comment.create.now', send_later: false }
end
```

*Hint*: `#{notifiable_type}.create` and `#{notifiable_type}.update` will be used as the key of tracked notifications.
You can override them by *Notifiable#notification_key_for_tracked_creation* and *Notifiable#notification_key_for_tracked_update*.
You can also specify key option in the *:tracked* statement.

As a default, the notifications will be generated synchronously along with model creation or update. If you want to generate notifications asynchronously, use *:notify_later* option with the *:tracked* option, like this:

```ruby
class Comment < ActiveRecord::Base
  acts_as_notifiable :users,
    targets: ->(comment, key) {
      ([comment.article.user] + comment.article.commented_users.to_a - [comment.user]).uniq
    },
    # It adds required callbacks to generate notifications asynchronously for creation of the notifiable model.
    tracked: { only: [:create], key: 'comment.create.later', notify_later: true }
end
```

### Displaying notifications

#### Preparing target notifications

To display notifications, you can use **notifications** association of the target model:

```ruby
# custom_notifications_controller.rb
def index
  @notifications = @target.notifications
end
```

You can also use several scope to filter notifications. For example, **unopened_only** to filter them unopened notifications only.

```ruby
# custom_notifications_controller.rb
def index
  @notifications = @target.notifications.unopened_only
end
```

Moreover, you can use **notification_index** or **notification_index_with_attributes** methods to automatically prepare notification index for the target.

```ruby
# custom_notifications_controller.rb
def index
  @notifications = @target.notification_index_with_attributes
end
```

#### Rendering notifications

You can use **render_notifications** helper in your views to show the notification index:

```erb
<%= render_notifications(@notifications) %>
```

We can set *:target* option to specify the target type of notifications:

```erb
<%= render_notifications(@notifications, target: :users) %>
```

*Note*: *render_notifications* is an alias for *render_notification* and does the same.

If you want to set notification index in the common layout, such as common header, you can use **render_notifications_of** helper like this:

```shared/_header.html.erb
<%= render_notifications_of current_user, index_content: :with_attributes %>
```

Then, content named **:notification_index** will be prepared and you can use it in your partial template.

```activity_notifications/notifications/users/_index.html.erb
...
<%= yield :notification_index %>
...
```

Sometimes, it's desirable to pass additional local variables to partials. It can be done this way:

```erb
<%= render_notification(@notification, locals: { friends: current_user.friends }) %>
```

#### Notification views

*activity_notification* looks for views in *app/views/activity_notification/notifications/:target* with **:key** of the notifications.

For example, if you have a notification with *:key* set to *"notification.comment.reply"* and rendered it with *:target* set to *:users*, the gem will look for a partial in *app/views/activity_notification/notifications/users/comment/_reply.html.(|erb|haml|slim|something_else)*.

*Hint*: the *"notification."* prefix in *:key* is completely optional, you can skip it in your projects or use this prefix only to make namespace.

If you would like to fallback to a partial, you can utilize the **:fallback** parameter to specify the path of a partial to use when one is missing:

```erb
<%= render_notification(@notification, target: :users, fallback: :default) %>
```

When used in this manner, if a partial with the specified *:key* cannot be located, it will use the partial defined in the *:fallback* instead. In the example above this would resolve to *activity_notification/notifications/users/_default.html.(|erb|haml|slim|something_else)*.

If you do not specify *:target* option like this,

```erb
<%= render_notification(@notification, fallback: :default) %>
```

the gem will look for a partial in *default* as the target type which means *activity_notification/notifications/default/_default.html.(|erb|haml|slim|something_else)*.

If a view file does not exist then *ActionView::MisingTemplate* will be raised. If you wish to fallback to the old behaviour and use an i18n based translation in this situation you can specify a *:fallback* parameter of *:text* to fallback to this mechanism like such:

```erb
<%= render_notification(@notification, fallback: :text) %>
```

Finally, default views of *activity_notification* depends on jQuery and you have to add requirements to *application.js* in your apps:

```app/assets/javascripts/application.js
//= require jquery
//= require jquery_ujs
```

#### i18n for notifications

Translations are used by the *#text* method, to which you can pass additional options in form of a hash. *#render* method uses translations when view templates have not been provided. You can render pure i18n strings by passing `{ i18n: true }` to *#render_notification* or *#render*.

Translations should be put in your locale *.yml* files as **text** field. To render pure strings from I18n example structure:

```yaml
notification:
  user:
    article:
      create:
        text: 'Article has been created'
      update:
        text: 'Article %{article_title} has been updated'
      destroy:
        text: 'Some user removed an article!'
    comment:
      create:
        text: '%{notifier_name} posted a comment on the article "%{article_title}"'
      post:
        text:
          one: "<p>%{notifier_name} posted a comment on your article %{article_title}</p>"
          other: "<p>%{notifier_name} posted %{count} comments on your article %{article_title}</p>"
      reply:
        text: "<p>%{notifier_name} and %{group_member_count} other people replied %{group_notification_count} times to your comment</p>"
        mail_subject: 'New comment on your article'
  admin:
    article:
      post:
        text: '[Admin] Article has been created'
```

This structure is valid for notifications with keys *"notification.comment.reply"* or *"comment.reply"*. As mentioned before, *"notification."* part of the key is optional. In addition for above example, `%{notifier_name}` and `%{article_title}` are used from parameter field in the notification record. Pluralization is supported (but optional) for grouped notifications using the `%{group_notification_count}` value.

### Customizing controllers (optional)

If the customization at the views level is not enough, you can customize each controller by following these steps:

1. Create your custom controllers using the generator with a target:

    ```console
    $ bin/rails generate activity_notification:controllers users
    ```

    If you specify *users* as the target, controllers will be created in *app/controllers/users*.
    And the notifications controller will look like this:

    ```ruby
    class Users::NotificationsController < ActivityNotification::NotificationsController
      # GET /:target_type/:target_id/notifications
      # def index
      #   super
      # end

      # ...

      # PUT /:target_type/:target_id/notifications/:id/open
      # def open
      #   super
      # end

      # ...
    end
    ```

2. Tell the router to use this controller:

    ```ruby
    notify_to :users, controller: 'users/notifications'
    ```

3. Finally, change or extend the desired controller actions.

    You can completely override a controller action
    ```ruby
    class Users::NotificationsController < ActivityNotification::NotificationsController
      # ...

      # PUT /:target_type/:target_id/notifications/:id/open
      def open
        # Custom code to open notification here

        # super
      end

      # ...
    end
