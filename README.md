# CircuitVerse

[![Financial Contributors on Open Collective](https://opencollective.com/CircuitVerse/all/badge.svg?label=financial+contributors)](https://opencollective.com/CircuitVerse) [![Slack](https://img.shields.io/badge/chat-on_slack-pink.svg)](https://join.slack.com/t/circuitverse-team/shared_invite/enQtNjc4MzcyNDE5OTA3LTdjYTM5NjFiZWZlZGI2MmU1MmYzYzczNmZlZDg5MjYxYmQ4ODRjMjQxM2UyMWI5ODUzODQzMDU2ZDEzNjI4NmE)
[![CircleCI](https://circleci.com/gh/CircuitVerse/CircuitVerse.svg?style=svg)](https://circleci.com/gh/CircuitVerse/CircuitVerse)
[![Coverage Status](https://coveralls.io/repos/github/CircuitVerse/CircuitVerse/badge.svg?branch=master)](https://coveralls.io/github/CircuitVerse/CircuitVerse?branch=master)

[Join Mailing List](https://circuitverse.us20.list-manage.com/subscribe?u=89207abda49deef3ba56f1411&id=29473194d6)

## Versions

- Ruby Version: ruby-2.6.5
- Rails Version: Rails 6.0.1
- PostgreSQL Version: 9.5

## Cloning Instructions

- `git clone https://github.com/CircuitVerse/CircuitVerse.git` this repository
- `cd CircuitVerse`

**Note :** If you want to contribute, first fork the original repository and clone the forked repository into your local machine followed by ```cd``` into the directory

```sh
git clone https://github.com/<username>/CircuitVerse.git
cd CircuitVerse
```

## Setup Instructions

Please go through the [Contribution Guidelines](CONTRIBUTING.md) before going forward with any development. This helps us keep the process streamlined and results in better PRs

**Note:** You might want to use the docker instructions if you do not want to setup your own environment.

* Install ruby using RVM, use ruby-2.6.5
* Install bundler : `gem install bundler`
* Install Dependencies: `bundle install`
* Configure your DB in config/database.yml, copy config/database.example.yml (Note : check for postgres password and update it in place of "postgres")
* Create database: `rails db:create`
* Run Migrations: `rails db:migrate`
* At this point, local development can be started with ```rails s -b 127.0.0.1 -p 8080```

### Additional setup instructions
[Yarn](https://yarnpkg.com/lang/en/) is a package manager for the JavaScript ecosystem.
CircuitVerse uses Yarn for frontend package and asset management.

If you encounter the following error,
```
Error: File to import not found or unreadable: bootstrap/scss/bootstrap.scss
```
run `yarn` to install frontend dependencies

Additional software:
* Install imagemagick
* Start Redis server process.
* To start sidekiq: `bundle exec sidekiq -e development -q default -q mailers -d -L tmp/sidekiq.log` (In development)

## Running Tests

Ensure all tests are passing locally before making a pull request. To run tests -
* `bundle exec rspec` or `bin/rake spec:all`

**Note:** To pass Systems Tests you need [Chrome Browser](https://www.google.com/chrome/browser/desktop/index.html) installed

## Docker Instructions

* Install docker and docker-compose
* Run: `docker-compose up`

If you need to rebuild, run this before `docker-compose up`
```
docker-compose down
docker-compose build --no-cache
```

### Setup in cloud
You can use gitpod to develop CircuitVerse in the cloud by following the steps mentioned [Here](https://github.com/CircuitVerse/CircuitVerse/wiki/Development-on-Gitpod)

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/CircuitVerse/CircuitVerse)

Pull Requests can be created by following these [Steps](https://github.com/CircuitVerse/CircuitVerse/wiki/Pull-Requests-using-Gitpod)

## Adding Environment Variables
* Make the following changes in your Google, Facebook, Github app:
1.  If you are running the application locally, update the site url field with ``http://localhost:8080`` and callback url field with ``http://localhost:3000/users/auth/(google or facebook or github)/callback``.
2.  If you are running the application in gitpod, update the site url field with ``gitpod url`` and callback url field with ```gitpod url/users/auth/(google or facebook or github)/callback``.
* Configure your env in .env, copy .env.example ( Note: check for the ``id`` and ``secret`` in your Google, Facebook, Github app and update it in its respective place. )
* After adding environment variables run ``dotenv rails server`` to start the application.
## Developer Instructions
Developers can quickly get started by setting up the dev environment using the instructions above. To seed the database with some sample data, run 'bundle exec rake db:seed'. The admin credentials after seeding will be as follows:
```
User: Admin
Email: admin@circuitverse.org
Password: password
```

For debugging include `binding.pry` anywhere inside the code to open the `pry` console.

## Additional setup instructions for Ubuntu
Additional instructions can be found [here](https://www.howtoforge.com/tutorial/ubuntu-ruby-on-rails/) and there are some extra notes for single user installations:

- If you are facing difficulties installing RVM, most probably it is because of an older version of rvm shipped with Ubuntu's desktop edition and updating the same resolves the problem.
- [Run Terminal as a login shell](https://rvm.io/integration/gnome-terminal/) so ruby and rails will be available.

  Removing RVM
  ```
  sudo apt-get --purge remove ruby-rvm` <br />
  sudo rm -rf /usr/share/ruby-rvm /etc/rvmrc /etc/profile.d/rvm.sh
  ```
  Installing new version of RVM
  ```
  curl -L https://get.rvm.io |
  bash -s stable --ruby --autolibs=enable --auto-dotfiles
  ```
- If you are facing errors running the `rails db:create` ensure that the socket file(i.e mysql.sock) is present in that location.   Some possible locations where it might be present is `/run/mysqld/mysqld.sock`  or `/var/lib/mysql/mysql.sock` and mention the exact location.


## Production Specific Instructions

```
bundle install --with pg --without development test
RAILS_ENV=production bundle exec rake assets:precompile
bundle exec sidekiq -e production -q default -q mailers -d -L tmp/sidekiq.log` (In production)
```

## Code of Conduct

This repository contains the [Code of Conduct](./code-of-conduct.md) of [CircuitVerse](https://circuitverse.org) Community.

## CircuitVerse Community

We would love to hear from you :smile:
Here are links to our:

[![Slack](https://img.shields.io/badge/chat-on_slack-pink.svg)](https://join.slack.com/t/circuitverse-team/shared_invite/enQtNjc4MzcyNDE5OTA3LTdjYTM5NjFiZWZlZGI2MmU1MmYzYzczNmZlZDg5MjYxYmQ4ODRjMjQxM2UyMWI5ODUzODQzMDU2ZDEzNjI4NmE)

[![Discord](https://img.shields.io/discord/552660710232948749.svg)](https://discord.gg/95x8H7b) - This is an official fan communication channel. Thanks to [@jbox1](https://github.com/jbox144) for this initiative.

## Contributors

### Code Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/CircuitVerse/CircuitVerse/graphs/contributors"><img src="https://opencollective.com/CircuitVerse/contributors.svg?width=890&button=false" /></a>

### Financial Contributors

Become a financial contributor and help us sustain our community. [[Contribute](https://opencollective.com/CircuitVerse/contribute)]

#### Individuals

<a href="https://opencollective.com/CircuitVerse"><img src="https://opencollective.com/CircuitVerse/individuals.svg?width=890"></a>

#### Organizations

Support this project with your organization. Your logo will show up here with a link to your website. [[Contribute](https://opencollective.com/CircuitVerse/contribute)]

<a href="https://opencollective.com/CircuitVerse/organization/0/website"><img src="https://opencollective.com/CircuitVerse/organization/0/avatar.svg"></a>
<a href="https://opencollective.com/CircuitVerse/organization/1/website"><img src="https://opencollective.com/CircuitVerse/organization/1/avatar.svg"></a>
<a href="https://opencollective.com/CircuitVerse/organization/2/website"><img src="https://opencollective.com/CircuitVerse/organization/2/avatar.svg"></a>
<a href="https://opencollective.com/CircuitVerse/organization/3/website"><img src="https://opencollective.com/CircuitVerse/organization/3/avatar.svg"></a>
<a href="https://opencollective.com/CircuitVerse/organization/4/website"><img src="https://opencollective.com/CircuitVerse/organization/4/avatar.svg"></a>
<a href="https://opencollective.com/CircuitVerse/organization/5/website"><img src="https://opencollective.com/CircuitVerse/organization/5/avatar.svg"></a>
<a href="https://opencollective.com/CircuitVerse/organization/6/website"><img src="https://opencollective.com/CircuitVerse/organization/6/avatar.svg"></a>
<a href="https://opencollective.com/CircuitVerse/organization/7/website"><img src="https://opencollective.com/CircuitVerse/organization/7/avatar.svg"></a>
<a href="https://opencollective.com/CircuitVerse/organization/8/website"><img src="https://opencollective.com/CircuitVerse/organization/8/avatar.svg"></a>
<a href="https://opencollective.com/CircuitVerse/organization/9/website"><img src="https://opencollective.com/CircuitVerse/organization/9/avatar.svg"></a>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) for details.
