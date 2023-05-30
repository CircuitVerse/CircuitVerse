# frozen_string_literal: true

require "logger"

namespace :migrate_assets do
  desc "Run all tasks"
  task to_active_storage: :environment do
    log_file = Rails.root.join("log/active_storage_migration.log")
    Logger.new(log_file)
    puts "Running all tasks and logging outputs to #{log_file}"
    original_stdout = $stdout.dup
    $stdout.reopen(log_file, "w")
    $stdout.sync = true
    begin
      Rake::Task["migrate_assets:paperclip"].invoke
      Rake::Task["migrate_assets:carrierwave"].invoke
      Rake::Task["migrate_assets:editname"].invoke
    rescue StandardError => e
      puts "Error occurred: #{e.message}"
      # Handle error or perform cleanup actions if needed
      # maybe store id's of all records(list, csv) that gave errors
    ensure
      $stdout.reopen(original_stdout)
    end
    $stdout.sync = true
  end

  desc "Migrate User profile_picture to S3"
  task paperclip: :environment do
    log_output("MIGRATING USER profile_picture to ActiveStorage \n")
    puts "Total User profile_pictures to be migrated- #{User.where.not(profile_picture_file_name: nil).count}"
    puts "Total Projects to be migrated - #{Project.where.not(image_preview: [nil, '']).count}"

    # Skips Users that dont have a profile_picture attached.
    # user.profile_picture.blank?
    #
    # Handle duplicate Records: that were already uploaded to AS tables during mirroring.
    # ActiveStorage::Attachment.where(record_id: user.id).present?
    #
    User.find_each do |user|
      next if user.profile_picture.blank? || ActiveStorage::Attachment.where(record_id: user.id).present?

      begin
        user.avatar.attach(
          io: File.open(user.profile_picture.path),
          filename: user.profile_picture_file_name,
          content_type: user.profile_picture_content_type
        )
        puts "migrated pfp with user_id: #{user.id}"
      rescue StandardError => e
        puts "Error occurred while attaching profile picture for user_id: #{user.id} - #{e.message}"
      end
    end
    puts "Finised Migrating User pfps"
    puts "*" * 60
  end

  desc "Migrate Circuit Preview to S3"
  task carrierwave: :environment do
    log_output("MIGRATING PROJECT image_preview to ActiveStorage \n")
    Project.find_each do |project|
      # Handle more missing cases:
      # Like For forked projects images are missing if original project is deleted.
      #
      # Skip if
      # 1. Image is missing (but record exists)- !project.image_preview.present?
      # 2. Image is already attached & present in S3 bucket.(handle duplicate records)

      next if project.image_preview.path.blank? || project.circuit_preview.attached?

      begin
        project.circuit_preview.attach(
          io: File.open(project.image_preview.path),
          filename: project.image_preview.identifier,
          content_type: "image/jpeg"
        )
        puts "migrated project with id: #{project.id}"
      rescue StandardError => e
        puts "Error occurred while attaching circuit_preview for project id: #{project.id} - #{e.message}"
      end
    end
    puts "Finished migrating all project image_previews"
    puts "*" * 60
  end

  desc "Rename circuit_preview to image_preview in ActiveStorage::Attachments table"
  task editname: :environment do
    # Rename records to in order to serve later with ActiveStorage
    # avatar to profile_picture
    log_output("RENAMING RECORDS \n")

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
    statistics
  end

  private

    def statistics
      puts "STATISTICS"
      puts "-" * 60
      puts "USERS:"
      puts "Users with profile_picture count - #{User.where.not(profile_picture_file_name: nil).count}"
      puts "ActiveStorage Attachment profile_picture count -
      #{ActiveStorage::Attachment.where(name: 'profile_picture').count}"

      puts "PROJECTS:"
      puts "Total Projects: #{Project.count}"
      puts "Projects with image_preview present count - #{Project.where.not(image_preview: [nil, '']).count}"
      puts "ActiveStorage Attachment image_preview count - #{ActiveStorage::Attachment.where(name: '').count}"
    end

    def log_output(message)
      puts message
      $stdout.flush
    end
end
