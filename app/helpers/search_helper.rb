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
    priority_countries = get_search_priority_countries(request)

    countries = ISO3166::Country.all.map do |country|
      {
        name: country.translations[I18n.locale.to_s] || country.name,
        code: country.alpha2,
        priority: priority_countries.include?(country.alpha2)
      }
    end

    countries.sort_by { |country| [country[:priority] ? 0 : 1, country[:name]] }
  end

  private

    def get_search_priority_countries(request)
      cached = get_cached_priority_countries(request)
      return cached if cached

      priority_countries = DEFAULT_PRIORITY_COUNTRY_CODES.dup
      return priority_countries unless request

      country_alpha2 = get_user_country_code(request)
      add_user_country_to_priorities(priority_countries, country_alpha2)

      cache_priority_countries(request, priority_countries)
    end

    def get_cached_priority_countries(request)
      request&.env&.dig("cv.priority_countries")
    end

    def get_user_country_code(request)
      geo_result = get_geo_data(request)
      return nil unless geo_result

      extract_country_code_from_geo_result(geo_result)
    rescue Geocoder::Error, Timeout::Error
      nil
    end

    def get_geo_data(request)
      # Prefer request.location if available
      geo_result = get_location_from_request(request)
      return geo_result if geo_result

      # Fallback to explicit IP lookup
      get_geo_data_from_ip(request)
    end

    def get_location_from_request(request)
      return nil unless request.respond_to?(:location)

      request.location
    rescue Geocoder::Error, Timeout::Error
      nil
    end

    def get_geo_data_from_ip(request)
      ip = begin
        request.remote_ip
      rescue StandardError
        nil
      end

      return nil unless ip

      Geocoder.search(ip).first
    end

    def extract_country_code_from_geo_result(geo_result)
      country_alpha2 = geo_result.respond_to?(:country_code) ? geo_result.country_code : nil

      if country_alpha2.nil? || country_alpha2.to_s.strip.empty?
        country_name = geo_result.respond_to?(:country) ? geo_result.country : nil
        country_alpha2 = normalize_country_to_alpha2(country_name)
      end

      country_alpha2
    end

    def add_user_country_to_priorities(priority_countries, country_alpha2)
      return priority_countries if country_alpha2.nil? || country_alpha2.to_s.strip.empty?

      code = country_alpha2.to_s.upcase
      priority_countries.prepend(code) unless priority_countries.include?(code)
      priority_countries
    end

    def cache_priority_countries(request, priority_countries)
      request.env["cv.priority_countries"] = priority_countries
      priority_countries
    end

    def normalize_country_to_alpha2(country_name)
      return nil if country_name.nil? || country_name.to_s.strip.empty?

      country = ISO3166::Country.find_country_by_name(country_name)
      country&.alpha2
    end
end
