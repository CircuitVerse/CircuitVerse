# frozen_string_literal: true

require "rake/clean"
CLOBBER.include "pkg"

require "bundler/gem_helper"
Bundler::GemHelper.install_tasks(name: "sentry-ruby")

require_relative "../lib/sentry/test/rake_tasks"

ISOLATED_SPECS = "spec/isolated/**/*_spec.rb"

Sentry::Test::RakeTasks.define_spec_tasks(
  isolated_specs_pattern: ISOLATED_SPECS,
  spec_exclude_pattern: ISOLATED_SPECS
)

task default: [:spec, :"spec:isolated"]
