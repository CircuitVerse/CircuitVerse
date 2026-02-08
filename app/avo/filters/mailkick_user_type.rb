# frozen_string_literal: true

class Avo::Filters::MailkickUserType < Avo::Filters::SelectFilter
  self.name = "User Type"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(user_type: value)
  end

  def options
    ::Mailkick::OptOut.distinct.pluck(:user_type).compact.sort.each_with_object({}) do |type, hash|
      hash[type] = type
    end
  end
end
