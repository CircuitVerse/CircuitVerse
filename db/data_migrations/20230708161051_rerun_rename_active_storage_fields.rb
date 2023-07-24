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

    # image_preview to circuit_preview
    sql1 = <<-SQL.squish
      UPDATE active_storage_attachments
      SET name = 'circuit_preview'
      WHERE name = 'image_preview';
    SQL
    ActiveRecord::Base.connection.execute(sql1)
    Rails.logger.info "Renamed all image_preview records to circuit_preview"
  end
end
