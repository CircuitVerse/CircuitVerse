# frozen_string_literal: true

module UsersLogixHelper
  def get_priority_countries
    priority_countries = ["IN"]
    geo_contry = Geocoder.search(request.remote_ip).first.country
    priority_countries.prepend(geo_contry) unless geo_contry.nil?
    priority_countries
  end
end
