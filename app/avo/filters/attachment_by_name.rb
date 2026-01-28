# frozen_string_literal: true

class Avo::Filters::AttachmentByName < Avo::Filters::SelectFilter
  self.name = "Attachment Name"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(name: value)
  end

  def options
    names = ActiveStorage::Attachment.distinct.pluck(:name).compact.sort

    options_hash = { "All" => nil }
    names.each do |name|
      options_hash[name.titleize] = name
    end

    options_hash
  end
end
