class RenameImagePreviewToCircuitPreview < ActiveRecord::DataMigration
  def up
    puts "Renaming image_preview records to circuit_preview in active_storage_attachments table"
    sql = <<-SQL.squish
      UPDATE active_storage_attachments
      SET name = 'circuit_preview '
      WHERE name = 'image_preview';
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "Finished renaming all records"
  end
end
