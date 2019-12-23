# frozen_string_literal: true

namespace :activestorage do
  task migratefiles: :environment do
    perform
  end
end

def perform
  models = [User]

  models.each do |model|
    attachments = model.column_names.map do |c|
      if c =~ /(.+)_file_name$/
        $1
      end
    end.compact

    attachments.each do |attachment|
      migrate_data(attachment, model)
    end
  end
end


def migrate_data(attachment, model)
  model.where.not("#{attachment}_file_name": nil).find_each do |instance|
    name = instance.send("#{attachment}_file_name")
    content_type = instance.send("#{attachment}_content_type")
    id = instance.id

    url = "public/system/users/profile_pictures/#{pad_id(id)}/original/#{name}"

    instance.send(attachment.to_sym).attach(
      io: open(url),
      filename: name,
      content_type: content_type
    )
  end
end

def pad_id(id)
  padded_id = id.to_s.rjust(9, "0")
  "#{padded_id[0, 3]}/#{padded_id[3, 3]}/#{padded_id[6, 3]}"
end
