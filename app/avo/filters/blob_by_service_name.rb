# frozen_string_literal: true

class Avo::Filters::BlobByServiceName < Avo::Filters::SelectFilter
  self.name = "Storage Service"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(service_name: value)
  end

  def options
    services = ActiveStorage::Blob.distinct.pluck(:service_name).compact.sort

    options_hash = { "All" => nil }
    services.each do |service|
      options_hash[service.titleize] = service
    end

    options_hash
  end
end
