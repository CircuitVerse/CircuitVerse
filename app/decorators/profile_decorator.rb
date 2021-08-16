# frozen_string_literal: true

class ProfileDecorator < SimpleDelegator
  def profile
    __getobj__
  end

  def member_since
    ((Time.now.to_i - profile.created_at.to_i) / 1.day)
  end

  def educational_institute
    profile.educational_institute || I18n.t("decorators.not_entered")
  end

  def country_name
    country = ISO3166::Country[profile.country]
    country ? country.translations[I18n.locale.to_s] || country.name : I18n.t("decorators.not_entered")
  end

  def mail_subscription
    profile.subscribed? ? I18n.t("decorators.subscribed") : I18n.t("decorators.not_subscribed")
  end

  def total_circuits
    profile.projects.exists? ? profile.projects.count : I18n.t("decorators.no_circuits")
  end
end
