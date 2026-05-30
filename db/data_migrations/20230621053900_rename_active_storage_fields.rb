# frozen_string_literal: true

require "logger"

class RenameActiveStorageFields < ActiveRecord::DataMigration
  def up
    log_file = Rails.root.join("log/rename-records.log")
    custom_logger = Logger.new(log_file)
    Rails.logger = custom_logger
    puts "Running all tasks and logging outputs to #{log_file}"
    rename_records
    statistics
  end

  def rename_records
    # avatar to profile_picture
    sql = <<-SQL.squish
      UPDATE active_storage_attachments
      SET name = 'profile_picture'
      WHERE name = 'avatar';
    SQL
    ActiveRecord::Base.connection.execute(sql)
    Rails.logger.info "Renamed all avatar records to profile_picture"

    # circuit_preview to image_preview
    sql1 = <<-SQL.squish
      UPDATE active_storage_attachments
      SET name = 'image_preview'
      WHERE name = 'circuit_preview';
    SQL
    ActiveRecord::Base.connection.execute(sql1)
    Rails.logger.info "Renamed all circuit_preview records to image_preview"
  end

  def statistics
    Rails.logger.info "STATISTICS"
    Rails.logger.info "Users with profile_picture count - #{User.where.not(profile_picture_file_name: nil).count}"
    Rails.logger.info "ActiveStorage Attachment profile_picture count - #{ActiveStorage::Attachment.where(name: 'profile_picture').count}"
    Rails.logger.info "Total Projects: #{Project.count}"
    Rails.logger.info "Projects with image_preview present count - #{Project.where.not(image_preview: [nil, '']).count}"
    Rails.logger.info "ActiveStorage Attachment image_preview count - #{ActiveStorage::Attachment.where(name: 'image_preview').count}"
  end
end
