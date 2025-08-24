# frozen_string_literal: true

module SearchHelper
  MAX_RESULTS_PER_PAGE = 9
  DEFAULT_PRIORITY_COUNTRY_CODES = ["IN"].freeze

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
    priority_country_codes = get_search_priority_countries(request)
    all_countries = ISO3166::Country.all.map do |country|
      {
        name: country.translations[I18n.locale.to_s] || country.name,
        code: country.alpha2
      }
    end

    # Separate priority and non-priority countries
    priority_countries = []
    regular_countries = []

    all_countries.each do |country|
      if priority_country_codes.include?(country[:code])
        priority_countries << country
      else
        regular_countries << country
      end
    end

    # Sort each group by name and combine
    priority_countries.sort_by! { |country| country[:name] }
    regular_countries.sort_by! { |country| country[:name] }

    priority_countries + regular_countries
  end

  private

    def get_search_priority_countries(request)
      priority_countries = DEFAULT_PRIORITY_COUNTRY_CODES.dup
      return priority_countries unless request

      geo_country_code = get_user_country_code_simple(request)
      if geo_country_code && !priority_countries.include?(geo_country_code)
        priority_countries.prepend(geo_country_code)
      end

      priority_countries
    end

    def get_user_country_code_simple(request)
      Geocoder.search(request.remote_ip).first&.country_code
    rescue Geocoder::Error, Timeout::Error
      nil
    end
end
