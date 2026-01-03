# Invisible Captcha

[![Gem](https://img.shields.io/gem/v/invisible_captcha.svg?style=flat-square)](https://rubygems.org/gems/invisible_captcha)
[![Build Status](https://github.com/markets/invisible_captcha/workflows/CI/badge.svg)](https://github.com/markets/invisible_captcha/actions)
[![codecov](https://codecov.io/gh/markets/invisible_captcha/branch/master/graph/badge.svg?token=nADSa6rbhM)](https://codecov.io/gh/markets/invisible_captcha)

> Complete and flexible spam protection solution for Rails applications.

Invisible Captcha provides different techniques to protect your application against spambots.

The main protection is a solution based on the `honeypot` principle, which provides a better user experience since there are no extra steps for real users, only for the bots.

Essentially, the strategy consists on adding an input field :honey_pot: into the form that:

- shouldn't be visible by the real users
- should be left empty by the real users
- will most likely be filled by spam bots

It also comes with:
- a time-sensitive :hourglass: form submission
- an IP based :mag: spinner validation

## Installation

Invisible Captcha is tested against Rails `>= 5.2` and Ruby `>= 2.7`.

Add this line to your Gemfile and then execute `bundle install`:

```ruby
gem 'invisible_captcha'
```

## Usage

View code:

```erb
<%= form_for(@topic) do |f| %>
  <%= f.invisible_captcha :subtitle %>
  <!-- or -->
  <%= invisible_captcha :subtitle, :topic %>
<% end %>
```

Controller code:

```ruby
class TopicsController < ApplicationController
  invisible_captcha only: [:create, :update], honeypot: :subtitle
end
```

This method will act as a `before_action` that triggers when spam is detected (honeypot field has some value). By default, it responds with no content (only headers: `head(200)`). This is a good default, since the bot will surely read the response code and will think that it has achieved to submit the form properly. But, anyway, you can define your own callback by passing a method to the `on_spam` option:

```ruby
class TopicsController < ApplicationController
  invisible_captcha only: [:create, :update], on_spam: :your_spam_callback_method

  private

  def your_spam_callback_method
    redirect_to root_path
  end
end
```

You should _not_ name your method `on_spam`, as this will collide with an internal method of the same name.

Note that it is not mandatory to specify a `honeypot` attribute (neither in the view nor in the controller). In this case, the engine will take a random field from `InvisibleCaptcha.honeypots`. So, if you're integrating it following this path, in your form:

```erb
<%= form_tag(new_contact_path) do |f| %>
  <%= invisible_captcha %>
<% end %>
```

In your controller:

```
invisible_captcha only: [:new_contact]
```

`invisible_captcha` sends all messages to `flash[:error]`. For messages to appear on your pages, add `<%= flash[:error] %>` to `app/views/layouts/application.html.erb` (somewhere near the top of your `<body>` element):

```erb
<!DOCTYPE html>
<html>
<head>
  <title>Yet another Rails app</title>
  <%= stylesheet_link_tag    "application", media: "all" %>
  <%= javascript_include_tag "application" %>
  <%= csrf_meta_tags %>
</head>
<body>
  <%= flash[:error] %>
  <%= yield %>
</body>
</html>
```

You can place `<%= flash[:error] %>` next to `:alert` and `:notice` message types, if you have them in your `app/views/layouts/application.html.erb`.

**NOTE:** This gem relies on data set by the backend, so in order to properly work, your forms should be rendered by Rails. Forms generated via JavaScript are not going to work well.

## Options and customization

This section contains a description of all plugin options and customizations.

### Plugin options:

You can customize:

- `sentence_for_humans`: text for real users if input field was visible. By default, it uses I18n (see below).
- `honeypots`: collection of default honeypots. Used by the view helper, called with no args, to generate a random honeypot field name. By default, a random collection is already generated. As the random collection is stored in memory, it will not work if you are running multiple Rails instances behind a load balancer (see [Multiple Rails instances](#multiple-rails-instances)). Beware that Chrome may ignore `autocomplete="off"`. Thus, consider not to use field names, which would be autocompleted, like for example `name`, `country`.
- `visual_honeypots`: make honeypots visible, also useful to test/debug your implementation.
- `timestamp_threshold`: fastest time (in seconds) to expect a human to submit the form (see [original article by Yoav Aner](https://blog.gingerlime.com/2012/simple-detection-of-comment-spam-in-rails/) outlining the idea). By default, 4 seconds. **NOTE:** It's recommended to deactivate the autocomplete feature to avoid false positives (`autocomplete="off"`).
- `timestamp_enabled`: option to disable the time threshold check at application level. Could be useful, for example, on some testing scenarios. By default, true.
- `timestamp_error_message`: flash error message thrown when form submitted quicker than the `timestamp_threshold` value. It uses I18n by default.
- `injectable_styles`: if enabled, you should call anywhere in your layout the following helper `<%= invisible_captcha_styles %>`. This allows you to inject styles, for example, in `<head>`. False by default, styles are injected inline with the honeypot.
- `spinner_enabled`: option to disable the IP spinner validation. By default, true.
- `secret`: customize the secret key to encode some internal values. By default, it reads the environment variable `ENV['INVISIBLE_CAPTCHA_SECRET']` and fallbacks to random value. Be careful, if you are running multiple Rails instances behind a load balancer, use always the same value via the environment variable.

To change these defaults, add the following to an initializer (recommended `config/initializers/invisible_captcha.rb`):

```ruby
InvisibleCaptcha.setup do |config|
  # config.honeypots           << ['more', 'fake', 'attribute', 'names']
  # config.visual_honeypots    = false
  # config.timestamp_threshold = 2
  # config.timestamp_enabled   = true
  # config.injectable_styles   = false
  # config.spinner_enabled     = true

  # Leave these unset if you want to use I18n (see below)
  # config.sentence_for_humans     = 'If you are a human, ignore this field'
  # config.timestamp_error_message = 'Sorry, that was too quick! Please resubmit.'
end
```

#### Multiple Rails instances

If you have multiple Rails instances running behind a load balancer, you have to share the same honeypots collection between the instances.

Either use a fixed collection or share them between the instances using `Rails.cache`:

```ruby
InvisibleCaptcha.setup do |config|
  config.honeypots = Rails.cache.fetch('invisible_captcha_honeypots') do
    (1..20).map { InvisibleCaptcha.generate_random_honeypot }
  end
end
```

Be careful also with the `secret` setting. Since it will be stored in-memory, if you are running this setup, the best idea is to provide the environment variable (`ENV['INVISIBLE_CAPTCHA_SECRET']`) from your infrastructure.

### Controller method options:

The `invisible_captcha` method accepts some options:

- `only`: apply to given controller actions.
- `except`: exclude to given controller actions.
- `honeypot`: name of custom honeypot.
- `scope`: name of scope, ie: 'topic[subtitle]' -> 'topic' is the scope. By default, it's inferred from the `controller_name`.
- `on_spam`: custom callback to be called on spam detection.
- `timestamp_enabled`: enable/disable this technique at action level.
- `on_timestamp_spam`: custom callback to be called when form submitted too quickly. The default action redirects to `:back` printing a warning in `flash[:error]`.
- `timestamp_threshold`: custom threshold per controller/action. Overrides the global value for `InvisibleCaptcha.timestamp_threshold`.
- `prepend`: the spam detection will run in a `prepend_before_action` if `prepend: true`, otherwise will run in a `before_action`.

### View helpers options:

Using the view/form helper you can override some defaults for the given instance. Actually, it allows to change:

- `sentence_for_humans`

```erb
<%= form_for(@topic) do |f| %>
  <%= f.invisible_captcha :subtitle, sentence_for_humans: "hey! leave this input empty!" %>
<% end %>
```
- `visual_honeypots`

```erb
<%= form_for(@topic) do |f| %>
  <%= f.invisible_captcha :subtitle, visual_honeypots: true %>
<% end %>
```

You can also pass html options to the input:

```erb
<%= invisible_captcha :subtitle, :topic, id: "your_id", class: "your_class" %>
```

### Spam detection notifications

In addition to the `on_spam` controller callback, you can use the [Active Support Instrumentation API](https://guides.rubyonrails.org/active_support_instrumentation.html) to set up a global event handler that fires whenever spam is detected. This is useful for advanced logging, background processing, etc.

To set up a global event handler, [subscribe](https://guides.rubyonrails.org/active_support_instrumentation.html#subscribing-to-an-event) to the `invisible_captcha.spam_detected` event in an initializer:

```ruby
# config/initializers/invisible_captcha.rb

ActiveSupport::Notifications.subscribe('invisible_captcha.spam_detected') do |*args, data|
  AwesomeLogger.warn(data[:message], data) # Log to an external logging service.
  SpamRequest.create(data)                 # Record the blocked request in your database.
end
```

The `data` passed to the subscriber is hash containing information about the request that was detected as spam. For example:

```ruby
{
  message: "Honeypot param 'subtitle' was present.",
  remote_ip: '127.0.0.1',
  user_agent: 'Chrome 77',
  controller: 'users',
  action: 'create',
  url: 'http://example.com/users',
  params: {
    topic: { subtitle: 'foo' },
    controller: 'users',
    action: 'create'
  }
}
```

**NOTE:** `params` will be filtered according to your `Rails.application.config.filter_parameters` configuration, making them (probably) safe for logging. But always double-check that you're not inadvertently logging sensitive form data, like passwords and credit cards.

### Content Security Policy

If you're using a Content Security Policy (CSP) in your Rails app, you will need to generate a nonce on the server, and pass `nonce: true` attribute to the view helper. Uncomment the following lines in your `config/initializers/content_security_policy.rb` file:

```ruby
# Be sure to restart your server when you modify this file.

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w(style-src)
```
Note that if you are already generating nonce for scripts, you'd have to include `script-src` to `content_security_policy_nonce_directives` as well:

```ruby
Rails.application.config.content_security_policy_nonce_directives = %w(script-src style-src)
```

And in your view helper, you need to pass `nonce: true` to the `invisible_captcha` helper:

```erb
<%= invisible_captcha nonce: true %>
```

**NOTE:** Content Security Policy can break your site! If you already run a website with third-party scripts, styles, images, and fonts, it is highly recommended to enable CSP in report-only mode and observe warnings as they appear. Learn more at MDN:

* https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
* https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

### I18n

`invisible_captcha` tries to use I18n when it's available by default. The keys it looks for are the following:

```yaml
en:
  invisible_captcha:
    sentence_for_humans: "If you are human, ignore this field"
    timestamp_error_message: "Sorry, that was too quick! Please resubmit."
```

You can override the English ones in your i18n config files as well as add new ones for other locales.

If you intend to use I18n with `invisible_captcha`, you _must not_ set `sentence_for_humans` or `timestamp_error_message` to strings in the setup phase.

## Testing your controllers

If you're encountering unexpected behaviour while testing controllers that use the `invisible_captcha` action filter, you may want to disable timestamp check for the test environment. Add the following snippet to the `config/initializers/invisible_captcha.rb` file:

```ruby
# Be sure to restart your server when you modify this file.

InvisibleCaptcha.setup do |config|
  config.timestamp_enabled = !Rails.env.test?
end
```

Another option is to wait for the timestamp check to be valid:

```ruby
# Maybe inside a before block
InvisibleCaptcha.init!
InvisibleCaptcha.timestamp_threshold = 1

# Before testing your controller action
sleep InvisibleCaptcha.timestamp_threshold
```

If you're using the "random honeypot" approach, you may want to set a known honeypot:

```ruby
config.honeypots = ['my_honeypot_field'] if Rails.env.test?
```

And for the "spinner validation" check, you may want to disable it:

```ruby
config.spinner_enabled = !Rails.env.test?
```

Or alternativelly, you should send a valid spinner value along your requests:

```ruby
# RSpec example
session[:invisible_captcha_spinner] = '32ab649161f9f6faeeb323746de1a25d'
post :create,  params: { topic: { title: 'foo' }, spinner: '32ab649161f9f6faeeb323746de1a25d' }
```

## Contribute

Any kind of idea, feedback or bug report are welcome! Open an [issue](https://github.com/markets/invisible_captcha/issues) or send a [pull request](https://github.com/markets/invisible_captcha/pulls).

## Development

Clone/fork this repository, start to hack on it and send a pull request.

Run the test suite:

```
$ bundle exec rspec
```

Run the test suite against all supported versions:

```
$ bundle exec appraisal install
$ bundle exec appraisal rspec
```

Run specs against specific version:

```
$ bundle exec appraisal rails-6.0 rspec
```

### Demo

Start a sample Rails app ([source code](spec/dummy)) with `InvisibleCaptcha` integrated:

```
$ bundle exec rake web # PORT=4000 (default: 3000)
```

## License

Copyright (c) Marc Anguera. Invisible Captcha is released under the [MIT](LICENSE) License.
