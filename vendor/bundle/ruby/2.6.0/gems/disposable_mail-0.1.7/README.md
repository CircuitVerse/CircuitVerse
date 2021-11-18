# DisposableMail
[![Build Status](https://travis-ci.org/oesgalha/disposable_mail.svg)](https://travis-ci.org/oesgalha/disposable_mail)
[![Code Climate](https://codeclimate.com/github/oesgalha/disposable_mail/badges/gpa.svg)](https://codeclimate.com/github/oesgalha/disposable_mail)

DisposableMail serves you a blacklist with domains from [disposable mail services](https://en.wikipedia.org/wiki/Disposable_email_address), like `mailinator.com` or `guerrillamail.com`. The list can be used to prevent sending mails to these domains (which probably won't be open), or to prevent dummy users registration in your website.

The domain list comes from this git repo:
https://github.com/martenson/disposable-email-domains

And this gem syncs with it through a git submodule (see the data folder).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'disposable_mail', '~> 0.1'
```

And then execute:

    $ bundle

## Usage

```ruby
require 'disposable_mail'

DisposableMail.list # => ["0815.ru", "0815.su", "0clickemail.com", "0-mail.com", "0wnd.net", "0wnd.org", "10minut.com.pl", ... ]

DisposableMail.include? "dummy@mailinator.com" # => true

DisposableMail.include? "bot@guerillamail.com" # => true

DisposableMail.include? "legit-person@yahoo.com" # => false
```

### Rails

If you include this gem in your rails project you can use a custom validator to block dummy users registration.

Suposse you don't want to create `User`s with a blacklisted mail domain, and your mail attribute is called `email`:

```ruby
class User < ActiveRecord::Base

  # validates :email, undisposable: true
  validates :email, undisposable: { message: 'Sorry, but we do not accept your mail provider.' }

end
```

Now if you try to create an user with a mail from the blacklisted domains, you get an AR validation error:

```ruby
user = User.create(email: "bot@mailinator.com")
user.errors.messages # => {:email=>["Sorry, but we do not accept your mail provider."]}
```

What if you want to create those users only in the test environment?

```ruby
class User < ActiveRecord::Base

  validates :email, undisposable: true, unless: -> { Rails.env.test? }

end
```

### I18n

If you don't specify the message in the model validation, Active Record will look for messages in this order:
```
activerecord.errors.models.user.attributes.email.undisposable
activerecord.errors.models.user.undisposable
activerecord.errors.messages.undisposable
errors.attributes.email.undisposable
errors.messages.undisposable
```

Here's an example of an `en.yml` file:

```yml
en:
  errors:
    attributes:
      email:
        undisposable: "domain is blocked"
```

You can use the aforementioned order of lookup to craft specific error messages.

This gem comes with default messages for the following locales:
- en
- pt-BR

## Contributing

1. Fork it ( https://github.com/oesgalha/disposable_mail/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
