# frozen_string_literal: true

module UsersCircuitverseHelper
  def get_priority_countries
    priority_countries = ["IN"]
    geo_contry = Geocoder.search(request.remote_ip).first&.country
    unless priority_countries.include?(geo_contry)
      priority_countries.prepend(geo_contry) unless geo_contry.nil?
    end
    priority_countries
  end
end
