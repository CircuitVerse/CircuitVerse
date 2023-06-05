# frozen_string_literal: true

require "logger"
require "redis"

class ConvertToActiveStorage < ActiveRecord::DataMigration
  def up
    log_file = Rails.root.join("log/active_storage_migration.log")
    redis = Redis.new

    if redis.exists("project_counter") == 1
      pcounter = redis.get("project_counter").to_i
      original_stdout = $stdout.dup
      $stdout.reopen(log_file, "w")
      $stdout.sync = true
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
      original_stdout = $stdout.dup
      $stdout.reopen(log_file, "w")
      $stdout.sync = true
      begin
        migrate_paperclip_assets
        migrate_carrierwave_assets
      rescue Interrupt
        puts "Interrupted!"
        return
      ensure
        $stdout.reopen(original_stdout)
      end
      $stdout.sync = true
    end
  end

  def migrate_paperclip_assets(counter = 0)
    log_output("MIGRATING USER profile_picture to ActiveStorage \n")
    puts "Total User profile_pictures to be migrated- #{User.where.not(profile_picture_file_name: nil).count}"
    puts "Total Projects to be migrated - #{Project.where.not(image_preview: [nil, '']).count}"
    interrupted = false
    trap("INT") do
      # If interrupted it is still running projects migration
      interrupted = true
      puts "Keyboard interrupt received."
    end

    User.where("id > ?", counter).find_each do |user|
      if interrupted
        puts "Cannot exit until avatar upload is complete..."
      end
      next if user.profile_picture.blank? || ActiveStorage::Attachment.where(record_id: user.id).present?

      begin
        image_file = File.open(user.profile_picture.path)
        blob = ActiveStorage::Blob.create_and_upload!(
          io: image_file,
          filename: user.profile_picture_file_name,
          content_type: user.profile_picture_content_type
        )
        user.avatar.attach(blob)
        image_file.close
        puts "migrated pfp with user_id: #{user.id}"
      rescue StandardError => e
        puts "Error occurred while attaching profile picture for user_id: #{user.id} - #{e.message}"
      end
    end
    puts "*" * 60
  end

  def migrate_carrierwave_assets(pcounter = 0)
    redis = Redis.new
    log_output("MIGRATING PROJECT image_preview to ActiveStorage \n")
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

  def log_output(message)
    puts message
    $stdout.flush
  end
end
