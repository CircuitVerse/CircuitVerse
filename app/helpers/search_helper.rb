# frozen_string_literal: true

module SearchHelper
  MAX_RESULTS_PER_PAGE = 9

  def query(resource, query_params)
    case resource
    when "Users"
      # User query
      return UsersQuery.new(query_params).results, "/users/circuitverse/search"
    when "Projects"
      # Project query
      return ProjectsQuery.new(query_params, Project.public_and_not_forked).results,
             "/projects/search"
    end
  end

  def countries_for_search_filters(request)
    priority_countries = get_search_priority_countries(request)

    ISO3166::Country.all.map do |country|
      {
        name: country.translations[I18n.locale.to_s] || country.name,
        code: country.alpha2,
        priority: priority_countries.include?(country.alpha2)
      }
    end.sort_by { |country| [country[:priority] ? 0 : 1, country[:name]] }
  end

  private

    def get_search_priority_countries(request)
      # Reuse the same logic as UsersCircuitverseHelper#get_priority_countries
      priority_countries = ["IN"]

      if request
        geo_country = Geocoder.search(request.remote_ip).first&.country
        priority_countries.prepend(geo_country) if priority_countries.exclude?(geo_country) && !geo_country.nil?
      end

      priority_countries
    end
end
