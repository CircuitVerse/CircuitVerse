#!/bin/bash
set -e

# Only submodule is cv-frontend-vue (separate codebase) — skip it.
# git submodule update --init

if [ ! -f config/database.yml ] || ! grep -q "host: db" config/database.yml 2>/dev/null; then
  cp config/database.docker.yml config/database.yml
fi

command -v bundler >/dev/null || gem install bundler --no-document
bundle config set without 'production'
bundle install --jobs "$(nproc)"
yarn install --frozen-lockfile

bundle exec rails db:prepare

# Seeds are slow; run only on fresh DB or when explicitly asked.
if [ "${SEED:-0}" = "1" ] || ! bundle exec rails runner 'exit(User.exists? ? 0 : 1)' >/dev/null 2>&1; then
  bundle exec rails db:seed
fi

if [ ! -f "./config/private.pem" ] && [ ! -f "./config/public.pem" ]; then
  openssl genrsa -out ./config/private.pem 2048
  openssl rsa -in ./config/private.pem -outform PEM -pubout -out ./config/public.pem
fi

echo "Setup done. Run: bin/dev"
