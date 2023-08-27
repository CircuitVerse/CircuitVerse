# frozen_string_literal: true

class RenameActiveStorageProfilePictures < ActiveRecord::DataMigration
  def up
    puts "Renaming avatar to profile_picture"
    sql = <<-SQL.squish
      UPDATE active_storage_attachments
      SET name = 'profile_picture'
      WHERE name = 'avatar';
    SQL
    ActiveRecord::Base.connection.execute(sql)
    Rails.logger.info "Renamed all avatar records to profile_picture"
  end
end
