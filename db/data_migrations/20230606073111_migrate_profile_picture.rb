# frozen_string_literal: true

require "logger"
require "redis"

class MigrateProfilePicture < ActiveRecord::DataMigration
  def up
    log_file = Rails.root.join("log/profile_picture_migration.log")
    custom_logger = Logger.new(log_file)
    Rails.logger = custom_logger
    last_migrated_user_id = redis.get("last_migrated_user_id").to_i
    Rails.logger.info "Migrating from user_id #{last_migrated_user_id + 1}"
    migrate_paperclip_assets(last_migrated_user_id)
  end

  def migrate_paperclip_assets(last_migrated_user_id = 0)
    User.where("id > ?", last_migrated_user_id).find_each do |user|
      next if !user.profile_picture.exists?
      next if ActiveStorage::Attachment.exists?(name: "avatar", record_id: user.id)

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
      rescue Interrupt
        break
      end
    end
  end

  def redis
    @_redis = Redis.new
  end
end
