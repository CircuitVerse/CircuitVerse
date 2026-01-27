# frozen_string_literal: true

class Avo::Resources::AhoyVisit < Avo::BaseResource
  self.title = :visit_token
  self.includes = [:user]
  self.model_class = ::Ahoy::Visit

  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_resource: true
    field :visit_token, as: :text
    field :visitor_token, as: :text
    field :user, as: :belongs_to, searchable: true

    field :ip, as: :text
    field :user_agent, as: :textarea
    field :referrer, as: :text
    field :referring_domain, as: :text
    field :landing_page, as: :text

    field :browser, as: :text
    field :os, as: :text
    field :device_type, as: :text

    field :country, as: :text
    field :region, as: :text
    field :city, as: :text

    field :utm_source, as: :text
    field :utm_medium, as: :text
    field :utm_term, as: :text
    field :utm_content, as: :text
    field :utm_campaign, as: :text

    field :app_version, as: :text
    field :os_version, as: :text
    field :platform, as: :text
    field :started_at, as: :date_time, sortable: true

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
