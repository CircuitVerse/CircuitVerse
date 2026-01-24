# frozen_string_literal: true

class Avo::Filters::GroupTokenExpiry < Avo::Filters::SelectFilter
  self.name = "Token Status"

  def apply(_request, query, value)
    case value
    when "valid"
      query.where("token_expires_at > ?", Time.zone.now)
    when "expired"
      query.where("token_expires_at <= ?", Time.zone.now).or(query.where(token_expires_at: nil))
    when "never_generated"
      query.where(token_expires_at: nil)
    else
      query
    end
  end

  def options
    {
      valid: "Valid Token",
      expired: "Expired Token",
      never_generated: "Never Generated"
    }
  end
end
