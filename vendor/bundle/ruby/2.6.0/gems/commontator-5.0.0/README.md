# Commontator

[![Gem Version](https://badge.fury.io/rb/commontator.svg)](http://badge.fury.io/rb/commontator)
[![Build Status](https://travis-ci.org/lml/commontator.svg?branch=master)](https://travis-ci.org/lml/commontator)
[![Code Climate](https://codeclimate.com/github/lml/commontator/badges/gpa.svg)](https://codeclimate.com/github/lml/commontator)
[![Code Coverage](https://codeclimate.com/github/lml/commontator/badges/coverage.svg)](https://codeclimate.com/github/lml/commontator)

Commontator is a Rails engine for comments. It is compatible with Rails 3.1+ and Rails 4.
Being an engine means it is fully functional as soon as you install and
configure the gem, providing models, views and controllers of its own.
At the same time, almost anything about it can be configured or customized to suit your needs.

## Installation

There are 4 steps you must follow to install commontator:

1. Gem

  Add this line to your application's Gemfile:

  ```rb
  gem 'commontator', '~> 4.11.1'
  ```

  And then execute:

  ```sh
  $ bundle install
  ```

2. Initializer and Migration

  Run the following command to copy commontator's initializer and migration to your app:

  ```sh
  $ rake commontator:install
  ```

  Or alternatively:

  ```sh
  $ rake commontator:install:initializers

  $ rake commontator:install:migrations
  ```

  And then execute:

  ```sh
  $ rake db:migrate
  ```

3. Configuration

  Change commontator's configurations to suit your needs by editing `config/initializers/commontator.rb`.
  Make sure to check that your configuration file is up to date every time you update the gem, as available options can change with each minor version.
  If you have deprecated options in your initializer, Commontator will issue warnings (usually printed to your console).

4. Routes

  Add this line to your Rails application's `routes.rb` file:

  ```rb
  mount Commontator::Engine => '/commontator'
  ```

  You can change the mount path if you would like a different one.

5. Stylesheets

  In order to display comment threads properly,
  you must add the following to your `application.css`:

  ```css
  *= require commontator/application
  ```

## Usage

Follow the steps below to add commontator to your models and views:

1. Models

  Add this line to your user model(s) (or any models that should be able to post comments):

  ```rb
  acts_as_commontator
  ```

  Add this line to any models you want to be able to comment on (i.e. models that have comment threads):

  ```rb
  acts_as_commontable
  ```

2. Views

  In the following instructions, `@commontable` is an instance of a model that `acts_as_commontable`.
  You must supply this variable to the views that will use Commontator.

  Wherever you would like to display comments, call `commontator_thread(@commontable)`:

  ```erb
  <%= commontator_thread(@commontable) %>
  ```

  This will create a link that can be clicked to display the comment thread.

  Note that model's record must already exist in the database, so do not use this in `new.html.erb`, `_form.html.erb` or similar views.
  We recommend you use this in the model's `show.html.erb` view or the equivalent for your app.

3. Controllers

  By default, the `commontator_thread` method only provides a link to the desired comment thread.
  Sometimes it may be desirable to have the thread display right away when the corresponding page is loaded.
  In that case, just add the following method call to the controller action that displays the page in question:

  ```rb
  commontator_thread_show(@commontable)
  ```

  Note that the call to `commontator_thread` in the view is still necessary in either case.

  The `commontator_thread_show` method checks the current user's read permission on the thread and will raise a
  Commontator::SecurityTransgression exception if the user is not allowed to read it, according to the options in the initializer.
  It is up to you to ensure that this method is only called if the user is authorized to read the thread.

That's it! Commontator is now ready for use.

## Emails

When you enable subscriptions, emails are sent automatically by Commontator. If sending emails, remember to add your host URL's to your environment files (test.rb, development.rb and production.rb):

```rb
config.action_mailer.default_url_options = { host: "www.example.com" }
```

Batch sending through Mailgun is also supported and automatically detected.

You may need to customize the mailer views with `rake commontator:copy:views` though only `app/views/commontator/subscriptions_mailer/` may be necessary. These in turn may require that you customize the localizations as well (see below for more details on that).

Sometimes you may need to add users automatically upon some event. For example, you may wish to automatically "subscribe" a (commontator) `user` to a (commontable) `event` so they get messages sent to the event automatically after joining the event. To do this you call `event.thread.subscribe(user)` when adding that `user` to that `event`.

## Voting

You can allow users to vote on each others' comments by adding the `acts_as_votable` gem to your gemfile:

```rb
gem 'acts_as_votable'
```

And enabling the relevant option in commontator's initializer:

```rb
config.comment_voting = :ld # See the initializer for available options
```

## Mentions

You can allow users to mention other users in the comments.
Mentioned users are automatically subscribed to the thread and receive email notifications.

First add the following to your application.js file:

```js
//= require commontator/application
```

Then enable mentions in commontator's initializer:

```rb
config.mentions_enabled = true
```

Finally configure the user_mentions_proc, which receives the current user,
the current thread, and the search query inputted by that user and should
return a relation containing the users that can be mentioned and match the
query string:

```rb
config.user_mentions_proc = ->(current_user, thread, query) { ... }
```

Please be aware that with mentions enabled, any registered user
can use the `user_mentions_proc` to search for other users.
Make sure to properly escape SQL in this proc and to not allow searches on sensitive fields.

Use '@' with at least three other characters to mention someone in a new/edited comment.

The mentions script assumes that commontator is mounted at `/commontator`,
so make sure that is indeed the case if you plan to use mentions.

## Browser Support

Commontator should work properly on any of the major browsers.
The mentions functionality won't work with IE before version 8.
To function properly, this gem requires that visitors to the site have javascript enabled.

## Customization

Copy commontator's files to your app using any of the following commands:

```sh
$ rake commontator:copy:locales

$ rake commontator:copy:images
$ rake commontator:copy:stylesheets

$ rake commontator:copy:views
$ rake commontator:copy:mailers
$ rake commontator:copy:helpers

$ rake commontator:copy:controllers
$ rake commontator:copy:models
```

You are now free to modify them and have any changes made manifest in your application.

If copying commontator's locales, please note that by default Rails will not autoload locales in subfolders of `config/locales` (like ours) unless you add the following to your application's configuration file:

```rb
config.i18n.load_path += Dir[root.join('config', 'locales', '**', '*.{rb,yml}')]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests for your feature
4. Implement your new feature
5. Test your feature (`rake`)
6. Commit your changes (`git commit -am 'Added some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create new Pull Request

## Development Environment Setup

1. Use bundler to install all dependencies:

  ```sh
  $ bundle install
  ```

2. Load the schema:

  ```sh
  $ rake db:schema:load
  ```

  Or if the above fails:

  ```sh
  $ bundle exec rake db:schema:load
  ```

## Testing

To run all existing tests for commontator, simply execute the following from the main folder:

```sh
$ rake
```

Or if the above fails:

```sh
$ bundle exec rake
```

## License

This gem is distributed under the terms of the MIT license.
See the MIT-LICENSE file for details.
