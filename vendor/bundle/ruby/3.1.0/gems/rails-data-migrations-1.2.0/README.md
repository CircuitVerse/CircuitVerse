# Rails Data Migrations

[![Build Status](https://travis-ci.org/OffgridElectric/rails-data-migrations.svg?branch=master)](https://travis-ci.org/OffgridElectric/rails-data-migrations)
[![Gem Version](https://badge.fury.io/rb/rails-data-migrations.svg)](https://badge.fury.io/rb/rails-data-migrations)

## Why?

Have you ever run into a problem when alongside with DB schema migrations (managed by `rake db:migrate` in Rails)
you have to often change your DB content, as well? If you read this, you probably tried to use schema migrations do change your data after schema changes, but this is not a recommended way and sometimes data changes could take a long time, so they will block your app at the deploy time.
Another approach is to use [rake tasks](https://robots.thoughtbot.com/data-migrations-in-rails) to run your changes after `db:migrate` or even independently. But this could also become a mess after some time if you have multiple developers in your project, and you need to change your data often.

This is our solution we came up with in our company - run data migration tasks in a `db:migrate`-like manner
 
## Usage
 
To create a data migration you need to run:
```
rails generate data_migration migration_name
```

and this will create a `migration_name.rb` file in `db/data_migrations` folder with a following content:
```ruby
class MigrationName < DataMigration
  def up
    # put your code here
  end
end
```
 
so all we need to do is to put some ruby code inside the `up` method.
 
Finally, at the release time, you need to run 
```
rake data:migrate
```
 
This will run all pending data migrations and store migration history in `data_migrations` table. You're all set.

## Rails Support

Rails 4.0 and higher

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-data-migrations'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-data-migrations

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run tests (`appraisal install && appraisal rake`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

