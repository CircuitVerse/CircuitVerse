# frozen_string_literal: true

class Avo::Resources::AhoyVisit < Avo::BaseResource
  self.title = :visit_token
  self.includes = [:user]
  self.model_class = ::Ahoy::Visit

  def fields
    basic_fields
    request_fields
    browser_device_fields
    location_fields
    utm_tracking_fields
    app_fields
    relationship_fields
  end

  private

    def basic_fields
      field :id, as: :id, link_to_resource: true
      field :visit_token, as: :text
      field :visitor_token, as: :text
      field :user, as: :belongs_to, searchable: true
      field :started_at, as: :date_time, sortable: true
    end

    def request_fields
      field :ip, as: :text
      field :user_agent, as: :textarea
      field :referrer, as: :text
      field :referring_domain, as: :text
      field :landing_page, as: :text
    end

    def browser_device_fields
      field :browser, as: :text
      field :os, as: :text
      field :device_type, as: :text
    end

    def location_fields
      field :country, as: :text
      field :region, as: :text
      field :city, as: :text
    end

    def utm_tracking_fields
      field :utm_source, as: :text
      field :utm_medium, as: :text
      field :utm_term, as: :text
      field :utm_content, as: :text
      field :utm_campaign, as: :text
    end

    def app_fields
      field :app_version, as: :text
      field :os_version, as: :text
      field :platform, as: :text
    end

    def relationship_fields
      field :events, as: :has_many, name: "Events"
    end
end
