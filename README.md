# README

## Versions
- Ruby Version: ruby-2.5.1
- Rails Version: Rails 5.1.6
- PostgreSQL Version: 9.5

## Setup Instructions

* Install ruby using RVM, use ruby-2.5.1
* Install Dependencies: `bundle install --without production`
* Configure your DB in config/database.yml, copy config/database.yml.example
* Create database: `rails db:create`
* Run Migrations: `rails db:migrate`
* At this point, local development can be started with ```rails s -b 127.0.0.1 -p 8080```

Additional software:
* Install imagemagick
* Start Redis server process.
* To start sidekiq: `bundle exec sidekiq -e development -q default -q mailers -d -L tmp/sidekiq.log` (In development)

## Docker Instructions

* Install docker and docker-compose
* Run: `docker-compose up`

If you need to rebuild, run this before `docker-compose up`
```
docker-compose down 
docker-compose build --no-cache
```

## Developer Instructions
Developers can quickly get started by setting up the dev environment using the instructions above. The database is seeded with the following admin account. 
```
User: Admin
Email: admin@circuitverse.org
Password: password
```

For debugging include `binding.pry` anywhere inside to code to open the `pry` console.

## Additional setup instructions for Ubuntu
Additional instructions can be found [here](https://www.howtoforge.com/tutorial/ubuntu-ruby-on-rails/) and there are some extra notes for single user installations:
- If setting up Postgres with these instructions, use your user name instead of 'rails_dev'.
- [Run Terminal as a login shell](https://rvm.io/integration/gnome-terminal/) so ruby and rails will be available.
- You can remove `gem mysql2` from the gemfile (but don't check it in), move `gem pg` up and create the database.yml file with just Postgres. Example:
```
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <your user name>
  password: <postgres password>

development:
  <<: *default
  database: circuitverse_development

test:
  <<: *default
  database: circuitverse_test

production:
  <<: *default
  database: circuitverse_production
  username: circuitverse
  password: <%= ENV['circuitverse_DATABASE_PASSWORD'] %>
```

## Production Specific Instructions

```
bundle install --without development test
RAILS_ENV=production bundle exec rake assets:precompile
bundle exec sidekiq -e production -q default -q mailers -d -L tmp/sidekiq.log` (In production)
```
