# rails_autolink

- http://github.com/tenderlove/rails_autolink


## Description

This is an extraction of the `auto_link` method from rails.  The `auto_link`
method was removed from Rails in version Rails 3.1.  This gem is meant to
bridge the gap for people migrating.

## Features

By default auto_link returns sanitized html_safe strings. This behaviour can
be overridden by setting the `:sanitize` option to false (thus making it
insecure if you don't have the content under control).

## Install

Add this line to your application's Gemfile:

```ruby
gem 'rails_autolink'
```

And then execute:

```bash
$ bundle install
```


## Synopsis

```ruby
require 'rails_autolink'

auto_link("Go to http://www.rubyonrails.org and say hello to david@loudthinking.com")
# => "Go to <a href=\"http://www.rubyonrails.org\">http://www.rubyonrails.org</a> and
#     say hello to <a href=\"mailto:david@loudthinking.com\">david@loudthinking.com</a>"

auto_link("Visit http://www.loudthinking.com/ or e-mail david@loudthinking.com", :link => :urls)
# => "Visit <a href=\"http://www.loudthinking.com/\">http://www.loudthinking.com/</a>
#     or e-mail david@loudthinking.com"

auto_link("Visit http://www.loudthinking.com/ or e-mail david@loudthinking.com", :link => :email_addresses)
# => "Visit http://www.loudthinking.com/ or e-mail <a href=\"mailto:david@loudthinking.com\">david@loudthinking.com</a>"

auto_link("Go to http://www.rubyonrails.org <script>Malicious code!</script>")
# => "Go to <a href=\"http://www.rubyonrails.org\">http://www.rubyonrails.org</a> "

auto_link("Go to http://www.rubyonrails.org <script>alert('Script!')</script>", :sanitize => false)
# => "Go to <a href=\"http://www.rubyonrails.org\">http://www.rubyonrails.org</a> <script>alert('Script!')</script>"

post_body = "Welcome to my new blog at http://www.myblog.com/.  Please e-mail me at me@email.com."
auto_link(post_body, :html => { :target => '_blank' }) do |text|
  truncate(text, :length => 15)
end
# => "Welcome to my new blog at <a href=\"http://www.myblog.com/\" target=\"_blank\">http://www.m...</a>.
```

## Requirements

- `rails` > `3.1`
