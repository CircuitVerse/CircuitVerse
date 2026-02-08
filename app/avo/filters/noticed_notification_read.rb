# frozen_string_literal: true

class Avo::Filters::NoticedNotificationRead < Avo::Filters::SelectFilter
  self.name = "Read Status"

  def apply(_request, query, value)
    case value
    when "read"
      query.where.not(read_at: nil)
    when "unread"
      query.where(read_at: nil)
    else
      query
    end
  end

  def options
    { read: "Read", unread: "Unread" }
  end
end
