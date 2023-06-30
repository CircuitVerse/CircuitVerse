# frozen_string_literal: true

require "logger"
require "redis"

class MigrateImagePreview < ActiveRecord::DataMigration
  def up
    log_file = Rails.root.join("log/image_preview_migration.log")
    custom_logger = Logger.new(log_file)
    Rails.logger = custom_logger
    last_migrated_project_id = redis.get("last_migrated_project_id").to_i
    Rails.logger.info "Migrating from project_id #{last_migrated_project_id + 1}"
    migrate_carrierwave_assets(last_migrated_project_id - 1)
  end

  def migrate_carrierwave_assets(last_migrated_project_id = 0)
    Project.where("id > ?", last_migrated_project_id).find_each do |project|
      next unless project.image_preview.file
      next if !project.image_preview.file.exists?
      next if ActiveStorage::Attachment.exists?(name: "circuit_preview", record_id: project.id)

      begin
        image_file = File.open(project.image_preview.path)
        blob = ActiveStorage::Blob.create_and_upload!(
          io: image_file,
          filename: project.image_preview.identifier,
          content_type: "image/jpeg"
        )
        project.circuit_preview.attach(blob)
        image_file.close
        Rails.logger.info "migrated circuit_preview with project_id: #{project.id}"
        redis.set("last_migrated_project_id", project.id)
      rescue Interrupt, StandardError
        break
      end
    end
  end

  def redis
    @_redis = Redis.new
  end
end
