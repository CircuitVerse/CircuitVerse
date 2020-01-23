# frozen_string_literal: true

module UsersLogixHelper
  def get_priority_countries
    priority_countries = ["IN"]
    geo_contry = Geocoder.search(request.remote_ip).first.country
    if not geo_contry.nil? then
      priority_countries.prepend(geo_contry)
    end
    priority_countries
  end
end
