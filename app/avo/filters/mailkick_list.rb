# frozen_string_literal: true

class Avo::Filters::MailkickList < Avo::Filters::SelectFilter
  self.name = "List"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(list: value)
  end

  def options
    ::Mailkick::OptOut.distinct.pluck(:list).compact.sort.each_with_object({}) do |list, hash|
      hash[list] = list
    end
  end
end
