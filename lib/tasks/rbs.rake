# frozen_string_literal: true

namespace :development do
  begin # rubocop:disable Style/RedundantBegin
    require "rbs_rails/rake_task"
    RbsRails::RakeTask.new
  rescue LoadError # rubocop:disable Lint/SuppressedException
  end
end
