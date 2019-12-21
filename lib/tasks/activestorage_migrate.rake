# frozen_string_literal: true

require "rake"
require "open-uri"
namespace :activestorage do
  task migrate: :environment do
    perform
  end
end


def perform
  get_blob_id = "LASTVAL()"

  ActiveRecord::Base.connection.raw_connection.prepare("active_storage_blob_statement", <<-SQL)
      INSERT INTO active_storage_blobs (
        key, filename, content_type, metadata, byte_size, checksum, created_at
      ) VALUES ($1, $2, $3, '{}', $4, $5, $6)
  SQL

  ActiveRecord::Base.connection.raw_connection
      .prepare("active_storage_attachment_statement", <<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES ($1, $2, $3, #{get_blob_id}, $4)
  SQL

  models = [User]

  models.each do |model|
    attachments = model.column_names.map do |c|
      if c =~ /(.+)_file_name$/
        $1
      end
    end.compact

    model.find_each.each do |instance|
      attachments.each do |attachment|
        if instance.send(attachment).path != nil
          make_active_storage_records(instance, attachment, model)
        end
      end
    end
  end
end

def make_active_storage_records(instance, attachment, model)
  blob_key = key(instance, attachment)
  filename = instance.send("#{attachment}_file_name")
  content_type = instance.send("#{attachment}_content_type")
  file_size = instance.send("#{attachment}_file_size")
  file_checksum = checksum(instance.send(attachment))
  created_at = instance.updated_at.iso8601

  blob_values = [blob_key, filename, content_type, file_size, file_checksum, created_at]

  ActiveRecord::Base.connection.raw_connection.exec_prepared(
    "active_storage_blob_statement",
      blob_values
  )

  blob_name = attachment
  record_type = model.name
  record_id = instance.id

  attachment_values = [blob_name, record_type, record_id, created_at]
  ActiveRecord::Base.connection.raw_connection.exec_prepared(
    "active_storage_attachment_statement",
      attachment_values
  )
end

def key(instance, attachment)
  SecureRandom.uuid
end

def checksum(attachment)
  # local files stored on disk:
  Digest::MD5.base64digest(File.read(attachment.path))

  # remote files stored on another person's computer:
  # url = attachment.url
  # Digest::MD5.base64digest(Net::HTTP.get(URI(url)))
end
