# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

*run sidekiq
*run redis-server

* ...

# Setup Instructions

* `bundle install`

* Configure your DB in config/database.yml

* `rails db:create`

* `rails db:migrate`

* install imagemagick

* Start Redis server process. 

* To start sidekiq:
`bundle exec sidekiq -e production -q default -q mailers -d -L tmp/sidekiq.log` (In production)

`bundle exec sidekiq -e development -q default -q mailers -d -L tmp/sidekiq.log` (In development)


