#!/bin/sh

git submodule update --init --recursive
# Setup database
cp config/database.docker.yml config/database.yml
createuser -s postgres
# Install ruby dependencies
gem install bundler
bundle install --without production
# Install node dependencies
yarn
# Setup database
bundle exec rails db:create
bundle exec rails db:schema:load
bundle exec rails db:migrate
bundle exec rails db:seed
# generate key-pair for jwt-auth
# if private.pem and public.pem does not exists
if [ ! -f "./config/private.pem" ] && [ ! -f "./config/public.pem" ]; then
  openssl genrsa -out ./config/private.pem 2048
  openssl rsa -in ./config/private.pem -outform PEM -pubout -out ./config/public.pem
fi
