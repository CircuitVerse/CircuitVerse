# frozen_string_literal: true

class Avo::Filters::AttachmentByRecordType < Avo::Filters::SelectFilter
  self.name = "Record Type"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(record_type: value)
  end

  def options
    record_types = ActiveStorage::Attachment.distinct.pluck(:record_type).compact.sort

    options_hash = { "All" => nil }
    record_types.each do |type|
      options_hash[type] = type
    end

    options_hash
  end
end
