# frozen_string_literal: true

require "logger"

class ConvertToActiveStorage < ActiveRecord::DataMigration
  def up
    log_file = Rails.root.join("log/active_storage_migration.log")
    if File.exist?(log_file)
      result = rerun(log_file)
      original_stdout = $stdout.dup
      $stdout.reopen(log_file, "w")
      $stdout.sync = true
      begin
        if result[0] == "pfp"
          # Wont be needed
          migrate_paperclip_assets(result[1])
          migrate_carrierwave_assets
        elsif result[0] == "image_preview"
          # Only part that will be used.
          migrate_carrierwave_assets(result[1])
        else
          puts "manual action needed"
        end
      rescue StandardError => e
        puts "Error occured -#{e.message}"
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
        user.avatar.attach(
          io: image_file,
          filename: user.profile_picture_file_name,
          content_type: user.profile_picture_content_type
        )
        image_file.close
        puts "migrated pfp with user_id: #{user.id}"
      rescue StandardError => e
        puts "Error occurred while attaching profile picture for user_id: #{user.id} - #{e.message}"
      end
    end
    puts "*" * 60
  end

  def migrate_carrierwave_assets(pcounter = 0)
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
        project.circuit_preview.attach(
          io: image_file,
          filename: project.image_preview.identifier,
          content_type: "image/jpeg"
        )
        puts "migrated project with id: #{project.id}"
        image_file.close
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

  def rerun(file_path)
    File.open(file_path, "r") do |file|
      last_line = file.readlines.second_to_last
      number = last_line.scan(/\d+/).first.to_i
      case last_line
      when /migrated pfp with id: /
        puts "Continuing Migrating pfps from user_id - #{number}"
        return ["pfp", number]
      when /migrated project with id: /
        puts "Continuing Migrating image_preview from id - #{number}"
        return ["image_preview", number]
      else
        puts "No matching action for the last line: #{last_line}, manual action needed"
        return ["nota"]
      end
    end
  end
end
