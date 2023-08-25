# frozen_string_literal: true

require "logger"
require "redis"
require "rake"
require "sidekiq"

class MigrateImagePreviewJob
  include Sidekiq::Job

  def perform
    Rails.application.load_tasks
    Rake::Task["data:migrate"].invoke
  end
end
