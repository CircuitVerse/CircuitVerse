#!/bin/bash

HEROKU_DEPLOYMENT_BRANCH=heroku-deployment

CURRENT_BRANCH=`git symbolic-ref --short HEAD`
git checkout -b $HEROKU_DEPLOYMENT_BRANCH
bundle install
sed -i "" -e "s/^\/Gemfile.lock/# \/Gemfile.lock/g" .gitignore
cp spec/rails_app/bin/webpack* bin/
git add .gitignore
git add Gemfile.lock
git add bin/webpack*
git commit -m "Add Gemfile.lock and webpack"
git push heroku ${HEROKU_DEPLOYMENT_BRANCH}:master --force
git checkout $CURRENT_BRANCH
git branch -D $HEROKU_DEPLOYMENT_BRANCH
