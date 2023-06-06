# frozen_string_literal: true

require "logger"
require "redis"

class MigrateImagePreview < ActiveRecord::DataMigration
  def up
    log_file = Rails.root.join("log/image_preview_migration.log")
    redis = Redis.new
    original_stdout = $stdout.dup
    $stdout.reopen(log_file, "w")
    $stdout.sync = true

    if redis.exists("project_counter") == 1
      pcounter = redis.get("project_counter").to_i
      puts "Running all tasks and logging outputs to #{log_file}"
      puts "Continuing migrating from project_id #{pcounter + 1}"
      begin
        migrate_carrierwave_assets(pcounter)
      rescue StandardError => e
        puts "Unexpected Error : #{e.message}"
      ensure
        $stdout.reopen(original_stdout)
      end
    else
      Logger.new(log_file)
      puts "Running all tasks and logging outputs to #{log_file}"
      begin
        migrate_carrierwave_assets
      rescue Interrupt
        puts "Interrupted!"
      ensure
        $stdout.reopen(original_stdout)
      end
      $stdout.sync = true
    end
  end

  def migrate_carrierwave_assets(pcounter = 0)
    redis = Redis.new
    puts "MIGRATING PROJECT image_preview to ActiveStorage"
    puts "Total Projects to be migrated - #{Project.where.not(image_preview: [nil, '']).count}"
    interrupted = false
    trap("INT") do
      interrupted = true
      puts "Keyboard interrupt received. Saving progress and exiting gracefully..."
      return
    end
    Project.where("id > ?", pcounter).find_each do |project|
      if interrupted
        break
      end
      next if project.image_preview.path.blank? || project.circuit_preview.attached?

      begin
        image_file = File.open(project.image_preview.path)
        blob = ActiveStorage::Blob.create_and_upload!(
          io: image_file,
          filename: project.image_preview.identifier,
          content_type: "image/jpeg"
        )
        project.circuit_preview.attach(blob)
        puts "migrated project with id: #{project.id}"
        image_file.close
        redis.set("project_counter", project.id)
      rescue StandardError => e
        puts "Error occurred while attaching circuit_preview for project id: #{project.id} - #{e.message}"
      end
    end
    puts "*" * 60
  end
end
