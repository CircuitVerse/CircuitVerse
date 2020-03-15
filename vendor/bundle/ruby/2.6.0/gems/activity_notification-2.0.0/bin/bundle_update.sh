#!/bin/bash

bundle update
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.2 bundle update
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-5.0 bundle update
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-5.1 bundle update
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-5.2 bundle update
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-6.0.rc bundle update
