# frozen_string_literal: true

class ProfileDecorator < SimpleDelegator
  # @return [User]
  def profile
    __getobj__
  end

  # @return [Integer] Number of days since user joined
  def member_since
    ((Time.now.to_i - profile.created_at.to_i) / 1.day)
  end

  # @return [String] User's educational institute
  def educational_institute
    profile.educational_institute || "Not Entered"
  end

  # @return [String] User's country name
  def country_name
    country = ISO3166::Country[profile.country]
    country ? country.translations[I18n.locale.to_s] || country.name : "Not Entered"
  end

  # @return [String] User's mail subscription status
  def mail_subscription
    profile.subscribed? ? "Subscribed" : "Not Subscribed"
  end

  # @return [String] No of circuits user has created
  def total_circuits
    profile.projects.exists? ? profile.projects.count : "No circuits"
  end
end
