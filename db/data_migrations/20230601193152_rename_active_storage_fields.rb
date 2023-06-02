# frozen_string_literal: true

require "logger"

class RenameActiveStorageFields < ActiveRecord::DataMigration
  def up
    log_file = Rails.root.join("log/rename-records.log")
    Logger.new(log_file)
    puts "Running all tasks and logging outputs to #{log_file}"
    original_stdout = $stdout.dup
    $stdout.reopen(log_file, "w")
    $stdout.sync = true
    rename_records
    statistics
    $stdout.reopen(original_stdout)
  end

  def rename_records
    puts "RENAMING RECORDS"
    puts "-" * 60
    sql = <<-SQL.squish
      UPDATE active_storage_attachments
      SET name = 'profile_picture'
      WHERE name = 'avatar';
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "Renamed all avatar records to profile_picture"

    # circuit_preview to image_preview
    sql1 = <<-SQL.squish
      UPDATE active_storage_attachments
      SET name = 'image_preview'
      WHERE name = 'circuit_preview';
    SQL
    ActiveRecord::Base.connection.execute(sql1)
    puts "Renamed all circuit_preview records to image_preview"
    puts "Ready to serve assets using ActiveStorage"
    puts "*" * 60
  end

  def statistics
    puts "STATISTICS"
    puts "-" * 60
    puts "USERS:"
    puts "Users with profile_picture count - #{User.where.not(profile_picture_file_name: nil).count}"
    puts "ActiveStorage Attachment profile_picture count - #{ActiveStorage::Attachment.where(name: 'profile_picture').count}"
    puts "PROJECTS:"
    puts "Total Projects: #{Project.count}"
    puts "Projects with image_preview present count - #{Project.where.not(image_preview: [nil, '']).count}"
    puts "ActiveStorage Attachment image_preview count - #{ActiveStorage::Attachment.where(name: 'image_preview').count}"
  end
end
