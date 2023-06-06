# frozen_string_literal: true

require "logger"
require "redis"

class MigrateProfilePicture < ActiveRecord::DataMigration
  def up
    log_file = Rails.root.join("log/profile_picture_migration.log")
    redis = Redis.new
    original_stdout = $stdout.dup
    $stdout.reopen(log_file, "w")
    $stdout.sync = true
    if redis.exists("user_counter") == 1
      user_counter = redis.get("user_counter").to_i
      puts "Continuing migrating from user_id #{user_counter + 1}"
      begin
        migrate_paperclip_assets(user_counter)
      rescue StandardError => e
        puts "Unexpected Error : #{e.message}"
      ensure
        $stdout.reopen(original_stdout)
      end
    else
      Logger.new(log_file)
      puts "Running all tasks and logging outputs to #{log_file}"
      begin
        migrate_paperclip_assets
      rescue Interrupt
        puts "Interrupted!"
        return
      ensure
        $stdout.reopen(original_stdout)
      end
      $stdout.sync = true
    end
  end

  def migrate_paperclip_assets(user_counter = 0)
    puts "MIGRATING USER profile_picture to ActiveStorage \n"
    puts "Total User profile_pictures to be migrated- #{User.where.not(profile_picture_file_name: nil).count}"
    redis = Redis.new
    interrupted = false
    trap("INT") do
      interrupted = true
      puts "Keyboard interrupt received... Saving progress and exiting gracefully..."
    end

    User.where("id > ?", user_counter).find_each do |user|
      if interrupted
        break
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
        redis.set("user_counter", user.id)
        sleep(3.seconds)
      rescue StandardError => e
        puts "Error occurred while attaching profile picture for user_id: #{user.id} - #{e.message}"
      end
    end
    puts "*" * 60
  end
end
