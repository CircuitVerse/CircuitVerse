# frozen_string_literal: true

class  RerunRenameActiveStorageFields< ActiveRecord::DataMigration
  def up
    puts "Re Running Renaming ActiveStorage Fields DataMigration"
    rename_records
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
end
