# frozen_string_literal: true

namespace :spec do
  begin # rubocop:disable Style/RedundantBegin
    require "rspec/core/rake_task"
    RSpec::Core::RakeTask.new(:all)
  rescue LoadError
  end
end
