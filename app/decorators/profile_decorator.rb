# frozen_string_literal: true

class ProfileDecorator < SimpleDelegator
  def profile
    __getobj__
  end

  def member_since
    ((Time.now.to_i - profile.created_at.to_i) / 1.day)
  end

  def educational_institute
    profile.educational_institute || "Not Entered"
  end

  def country_name
    country = ISO3166::Country[profile.country]
    country ? country.translations[I18n.locale.to_s] || country.name : "Not Entered"
  end

  def mail_subscription
    profile.subscribed? ? "Subscribed" : "Not Subscribed"
  end
end
