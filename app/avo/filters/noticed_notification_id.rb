# frozen_string_literal: true

class Avo::Filters::NoticedNotificationId < Avo::Filters::TextFilter
  self.name = "ID"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(id: value.to_i)
  end
end
