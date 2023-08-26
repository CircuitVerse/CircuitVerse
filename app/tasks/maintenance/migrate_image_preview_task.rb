# frozen_string_literal: true

require "redis"
require "logger"

module Maintenance
  class MigrateImagePreviewTask < MaintenanceTasks::Task
    delegate :count, to: :collection

    Rails.logger = Logger.new(Rails.root.join("log/redo_image_preview_migration.log"))
    def collection
      Project.in_batches
    end

    def process(project_batch)
      last_migrated_project_id = redis.get("last_migrated_project_id").to_i
      project_batch.where("id > ?", last_migrated_project_id).find_each do |project|
        next unless project.image_preview.file
        next unless project.image_preview.file.exists?
        next if project.circuit_preview.attached?

        begin
          attach_circuit_preview_sidekiq(project)
          Rails.logger.info "Finished migrating circuit_preview with project_id: #{project.id}"
          redis.set("last_migrated_project_id", project.id)
        rescue StandardError => e
          # :nocov:
          Rails.logger.error "Error migrating project_id #{project.id}: #{e.message}"
          # :nocov:
        end
      end
    end

    def redis
      @redis ||= Redis.new
    end

    private

      def attach_circuit_preview_sidekiq(project)
        File.open(project.image_preview.path) do |image_file|
          blob = ActiveStorage::Blob.create_and_upload!(io: image_file, filename: project.image_preview.identifier,
                                                        content_type: "image/jpeg")
          project.circuit_preview.attach(blob)
        end
      end
  end
end
