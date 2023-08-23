# frozen_string_literal: true

require "logger"
require "redis"

class RedoImagePreviewMigration < ActiveRecord::DataMigration
  def up
    Rails.logger = Logger.new(Rails.root.join("log/redo_image_preview_migration.log"))
    last_migrated_project_id = redis.get("last_migrated_project_id").to_i
    Rails.logger.info "Migrating from project_id #{last_migrated_project_id + 1}"
    migrate_carrierwave_assets(last_migrated_project_id - 1)
  end

  def migrate_carrierwave_assets(last_migrated_project_id = 0)
    Project.where("id > ?", last_migrated_project_id).find_each(batch_size: 100) do |project|
      next unless project.image_preview.file
      next if !project.image_preview.file.exists?
      next if project.circuit_preview.attached?

      begin
        File.open(project.image_preview.path) do |image_file|
          blob = ActiveStorage::Blob.create_and_upload!(
            io: image_file,
            filename: project.image_preview.identifier,
            content_type: "image/jpeg"
          )
          project.circuit_preview.attach(blob)
        end
        Rails.logger.info "Finished migrating circuit_preview with project_id: #{project.id}"
        redis.set("last_migrated_project_id", project.id)
      rescue StandardError => e
        Rails.logger.error "Error migrating project_id #{project.id}: #{e.message}"
        next
      end
    end
  end

  def redis
    @_redis = Redis.new
  end
end
