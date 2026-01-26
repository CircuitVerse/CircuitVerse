# frozen_string_literal: true

class Avo::Resources::AhoyVisit < Avo::BaseResource
  self.title = :visit_token
  self.includes = [:user]
  self.model_class = ::Ahoy::Visit

  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_resource: true
    field :visit_token, as: :text, readonly: true
    field :visitor_token, as: :text, readonly: true
    field :user, as: :belongs_to, searchable: true

    field :ip, as: :text, readonly: true
    field :user_agent, as: :textarea, readonly: true
    field :referrer, as: :text, readonly: true
    field :referring_domain, as: :text, readonly: true
    field :landing_page, as: :text, readonly: true

    field :browser, as: :text, readonly: true
    field :os, as: :text, readonly: true
    field :device_type, as: :text, readonly: true

    field :country, as: :text, readonly: true
    field :region, as: :text, readonly: true
    field :city, as: :text, readonly: true

    field :utm_source, as: :text, readonly: true
    field :utm_medium, as: :text, readonly: true
    field :utm_term, as: :text, readonly: true
    field :utm_content, as: :text, readonly: true
    field :utm_campaign, as: :text, readonly: true

    field :app_version, as: :text, readonly: true
    field :os_version, as: :text, readonly: true
    field :platform, as: :text, readonly: true

    field :started_at, as: :date_time, readonly: true, sortable: true

    field :ahoy_events, as: :has_many, name: "Events"
  end
  # rubocop:enable Metrics/MethodLength

  def filters
    filter Avo::Filters::AhoyVisitBrowser
    filter Avo::Filters::AhoyVisitDeviceType
    filter Avo::Filters::AhoyVisitCountry
    filter Avo::Filters::AhoyVisitStartedAt
  end

  def actions
    action Avo::Actions::ExportAhoyVisits
  end
end
