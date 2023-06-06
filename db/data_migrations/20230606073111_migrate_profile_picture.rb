# frozen_string_literal: true

require "logger"
require "redis"

class MigrateProfilePicture < ActiveRecord::DataMigration
  def up
    log_file = Rails.root.join("log/profile_picture_migration.log")
    custom_logger = Logger.new(log_file)
    Rails.logger = custom_logger
    redis = Redis.new
    if redis.exists("last_migrated_user_id") == 1
      last_migrated_user_id = redis.get("last_migrated_user_id").to_i
      Rails.logger.info "Continuing migrating from user_id #{last_migrated_user_id + 1}"
      migrate_paperclip_assets(last_migrated_user_id)
    else
      Rails.logger.info "Migrating User pfp to ActiveStorage & logging output to - #{log_file}"
      Rails.logger.info "Total User profile_pictures to be migrated- #{User.where.not(profile_picture_file_name: nil).count}"
      migrate_paperclip_assets
    end
  end

  def migrate_paperclip_assets(last_migrated_user_id = 0)
    redis = Redis.new
    interrupted = false
    trap("INT") do
      interrupted = true
      puts "Keyboard interrupt received. Saving progress and exiting gracefully..."
    end

    User.where("id > ?", last_migrated_user_id).find_each do |user|
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
        Rails.logger.info "migrated pfp with user_id: #{user.id}"
        redis.set("last_migrated_user_id", user.id)
      rescue StandardError => e
        Rails.logger.info "Error occurred while attaching profile picture for user_id: #{user.id} - #{e.message}"
      end
    end
  end
end
