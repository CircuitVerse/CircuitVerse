# SimpleDiscussion

SimpleDiscussion is a Rails forum gem extracting the [forum from GoRails](https://gorails.com/forum). It includes categories, simple moderation, the ability to mark threads as solved, and more.

Out of the box, SimpleDiscussion comes with styling for Boostrap v4 but you're free to customize the UI as much as you like by installing the views and tweaking the HTML.

[![GoRails Forum](https://d3vv6lp55qjaqc.cloudfront.net/items/3j2p3o1j0d1O0R1w2j1Y/Screen%20Shot%202017-08-08%20at%203.12.01%20PM.png?X-CloudApp-Visitor-Id=51470&v=d439dcae)](https://d3vv6lp55qjaqc.cloudfront.net/items/3j2p3o1j0d1O0R1w2j1Y/Screen%20Shot%202017-08-08%20at%203.12.01%20PM.png?X-CloudApp-Visitor-Id=51470&v=d439dcae)

## Installation

Before you get started, SimpleDiscussion requires a `User` model in your application (for now).

Add this line to your application's Gemfile:

```ruby
gem 'simple_discussion'
```

And then execute:

```bash
bundle
```

Install the migrations and migrate:

```bash
rails simple_discussion:install:migrations
rails db:migrate
```

Add SimpleDiscussion to your `User` model. The model **must** have `name` method which will be used to display the user's name on the forum. Currently only a model named `User` will work, but this will be fixed shortly.

```ruby
class User < ActiveRecord::Base
  include SimpleDiscussion::ForumUser

  def name
    "#{first_name} #{last_name}"
  end
end
```

Optionally, you can add a `moderator` flag to the `User` model to allow users to edit threads and posts they didn't write.

```bash
rails g migration AddModeratorToUsers moderator:boolean
rails db:migrate
```

Add the following line to your `config/routes.rb` file:

```ruby
mount SimpleDiscussion::Engine => "/forum"
```

Lastly, add the CSS to your `application.css` to load some default styles.

```scss
*= require simple_discussion
```

## Usage

To get all the basic functionality, the only thing you need to do is add a link to SimpleDiscussion in your navbar.

```erb
<%= link_to "Forum", simple_discussion_path %>
```

This will take the user to the views inside the Rails engine and that's all you have to do!

### Customizing All The Things!

If you'd like to customize the views that SimpleDiscussion uses, you can install the views to your Rails app:

```bash
rails g simple_discussion:views
```

You can also install a copy of the SimpleDiscussion controllers for advanced customization:

```bash
rails g simple_discussion:controllers
```

Helpers are available for override as well. They are used for rendering the user avatars, text formatting, and more.

```bash
rails g simple_discussion:helpers
```

**NOTE:** Keep in mind that the more customization you do, the tougher gem upgrades will be in the future.

### Email And Slack Notifications

By default, SimpleDiscussion will attempt to send email and slack notifications for users subscribed to threads. To turn these off you can do the following in `config/initializers/simple_discussion.rb`

```ruby
SimpleDiscussion.setup do |config|
  config.send_email_notifications = false # Default: true
  config.send_slack_notifications = false # Default: true
end
```

Slack notifications require you to set `simple_discussion_slack_url` in your `config/secrets.yml`. If you don't have this value set, it will not attempt Slack notifications even if they are enabled.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/excid3/simple_discussion. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleDiscussion project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/excid3/simple_discussion/blob/master/CODE_OF_CONDUCT.md).
