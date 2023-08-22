# !/bin/sh

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