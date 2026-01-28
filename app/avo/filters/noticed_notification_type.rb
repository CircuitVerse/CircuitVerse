# frozen_string_literal: true

class Avo::Filters::NoticedNotificationType < Avo::Filters::SelectFilter
  self.name = "Type"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(type: value)
  end

  def options
    ::NoticedNotification.distinct.pluck(:type).compact.sort.each_with_object({}) do |type, hash|
      hash[type] = type
    end
  end
end
