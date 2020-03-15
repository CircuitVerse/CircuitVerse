#!/bin/bash

HEROKU_DEPLOYMENT_BRANCH=heroku-deployment

CURRENT_BRANCH=`git symbolic-ref --short HEAD`
git checkout -b $HEROKU_DEPLOYMENT_BRANCH
bundle install
sed -i "" -e "s/^\/Gemfile.lock/# \/Gemfile.lock/g" .gitignore
git add .gitignore
git add Gemfile.lock
git commit -m "Add Gemfile.lock"
git push heroku ${HEROKU_DEPLOYMENT_BRANCH}:master --force
git checkout $CURRENT_BRANCH
git branch -D $HEROKU_DEPLOYMENT_BRANCH
