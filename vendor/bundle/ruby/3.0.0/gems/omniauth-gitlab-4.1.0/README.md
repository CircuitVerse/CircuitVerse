# Omniauth::Gitlab

[![Join the chat at https://gitter.im/linchus/omniauth-gitlab](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/linchus/omniauth-gitlab?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is the OAuth2 strategy for authenticating to your GitLab service.

## Requirements

Gitlab 7.7.0+
 
## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-gitlab'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-gitlab

## Basic Usage

    use OmniAuth::Builder do
      provider :gitlab, ENV['GITLAB_KEY'], ENV['GITLAB_SECRET']
    end

## Standalone Usage

    use OmniAuth::Builder do
      provider :gitlab, ENV['GITLAB_KEY'], ENV['GITLAB_SECRET'],
        {
           client_options: {
             site: 'https://gitlab.YOURDOMAIN.com'
           }
        }
    end

## Custom scopes

By default, the `api` scope is requested and must be allowed in GitLab's application configuration. To use different scopes:

    use OmniAuth::Builder do
      provider :gitlab, ENV['GITLAB_KEY'], ENV['GITLAB_SECRET'], scope: 'read_user openid'
    end

Requesting a scope that is not configured will result the error "The requested scope is invalid, unknown, or malformed.".

## Old API version

API V3 will be unsupported from GitLab 9.5 and will be removed in GitLab 9.5 or later.

[https://gitlab.com/help/api/v3_to_v4.md](https://gitlab.com/help/api/v3_to_v4.md)

If you use GitLab 9.0 and below you could configure V3 API:

    use OmniAuth::Builder do
      provider :gitlab, ENV['GITLAB_KEY'], ENV['GITLAB_SECRET'],
        {
           client_options: {
             site: 'https://gitlab.YOURDOMAIN.com/api/v3'
           }
        }
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
