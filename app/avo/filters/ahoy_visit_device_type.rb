# frozen_string_literal: true

class Avo::Filters::AhoyVisitDeviceType < Avo::Filters::SelectFilter
  self.name = "Device Type"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(device_type: value)
  end

  def options
    ::Ahoy::Visit.distinct.pluck(:device_type).compact.sort.each_with_object({}) do |device, hash|
      hash[device] = device
    end
  end
end
