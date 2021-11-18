## Testing

### Testing your application

First, you need to configure ActivityNotification as described above.

#### Testing notifications with RSpec
Prepare target and notifiable model instances to test generating notifications (e.g. `@user` and `@comment`).
Then, you can call notify API and test if notifications of the target are generated.
```ruby
# Prepare
@article_author = create(:user)
@comment = @article_author.articles.create.comments.create
expect(@article_author.notifications.unopened_only.count).to eq(0)

# Call notify API
@comment.notify :users

# Test generated notifications
expect(@article_author_user.notifications.unopened_only.count).to eq(1)
expect(@article_author_user.notifications.unopened_only.latest.notifiable).to eq(@comment)
```

#### Testing email notifications with RSpec
Prepare target and notifiable model instances to test sending notification email.
Then, you can call notify API and test if notification email is sent.
```ruby
# Prepare
@article_author = create(:user)
@comment = @article_author.articles.create.comments.create
expect(ActivityNotification::Mailer.deliveries.size).to eq(0)

# Call notify API and send email now
@comment.notify :users, send_later: false

# Test sent notification email
expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(@article_author.email)
```
Note that notification email will be sent asynchronously without false as *:send_later* option.
```ruby
# Prepare
include ActiveJob::TestHelper
@article_author = create(:user)
@comment = @article_author.articles.create.comments.create
expect(ActivityNotification::Mailer.deliveries.size).to eq(0)

# Call notify API and send email asynchronously as default
# Test sent notification email with ActiveJob queue
expect {
  perform_enqueued_jobs do
    @comment.notify :users
  end
}.to change { ActivityNotification::Mailer.deliveries.size }.by(1)
expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(@article_author.email)
```

### Testing gem alone

#### Testing with RSpec
Pull git repository and execute RSpec.
```console
$ git pull https://github.com/simukappu/activity_notification.git
$ cd activity_notification
$ bundle install —path vendor/bundle
$ bundle exec rspec
  - or -
$ bundle exec rake
```

##### Testing with DynamoDB Local
You can use [DynamoDB Local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html) to test Amazon DynamoDB integration in your local environment.

At first, set up DynamoDB Local by install script:
```console
$ bin/install_dynamodblocal.sh
```
Then, start DynamoDB Local by start script:
```console
$ bin/start_dynamodblocal.sh
```
And you can stop DynamoDB Local by stop script:
```console
$ bin/stop_dynamodblocal.sh
```

In short, you can test DynamoDB integration by the following step:
```console
$ git pull https://github.com/simukappu/activity_notification.git
$ cd activity_notification
$ bundle install —path vendor/bundle
$ bin/install_dynamodblocal.sh
$ bin/start_dynamodblocal.sh
$ AN_ORM=dynamoid bundle exec rspec
```

#### Example Rails application
Test module includes example Rails application in *[spec/rails_app](/spec/rails_app)*. You can run the example application as common Rails application.
```console
$ cd spec/rails_app
$ bin/rake db:migrate
$ bin/rake db:seed
$ bin/rails server
```
Then, you can access <http://localhost:3000> for the example application.

##### Run with your local database
As default, example Rails application runs with local SQLite database in *spec/rails_app/db/development.sqlite3*.
This application supports to run with your local MySQL, PostgreSQL, MongoDB.
Set **AN_TEST_DB** environment variable as follows.

To use MySQL:
```console
$ export AN_TEST_DB=mysql
```
To use PostgreSQL:
```console
$ export AN_TEST_DB=postgresql
```
To use MongoDB:
```console
$ export AN_TEST_DB=mongodb
```
When you set **mongodb** as *AN_TEST_DB*, you have to use *activity_notification* with MongoDB. Also set **AN_ORM** like:
```console
$ export AN_ORM=mongoid
```

You can also run this Rails application in cross database environment like these:

To use MySQL for your application and use MongoDB for *activity_notification*:
```console
$ export AN_ORM=mongoid AN_TEST_DB=mysql
```
To use PostgreSQL for your application and use Amazon DynamoDB for *activity_notification*:
```console
$ export AN_ORM=dynamoid AN_TEST_DB=postgresql
```

Then, configure *spec/rails_app/config/database.yml* or *spec/rails_app/config/mongoid.yml*, *spec/rails_app/config/dynamoid.rb* as your local database.
Finally, run database migration, seed data script and the example appliation.
```console
$ cd spec/rails_app
$ # You don't need migration when you use MongoDB only (AN_ORM=mongoid and AN_TEST_DB=mongodb)
$ bin/rake db:migrate
$ bin/rake db:seed
$ bin/rails server Puma
```
