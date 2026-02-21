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
    all_countries = build_country_list
    priority_countries, regular_countries = separate_countries_by_priority(all_countries, priority_country_codes)
    sort_and_combine_countries(priority_countries, regular_countries)
  end

  private

    def build_country_list
      ISO3166::Country.all.map do |country|
        {
          name: country.translations[I18n.locale.to_s] || country.name,
          code: country.alpha2
        }
      end
    end

    def separate_countries_by_priority(all_countries, priority_country_codes)
      priority_countries = []
      regular_countries = []

      all_countries.each do |country|
        if priority_country_codes.include?(country[:code])
          priority_countries << country
        else
          regular_countries << country
        end
      end

      [priority_countries, regular_countries]
    end

    def sort_and_combine_countries(priority_countries, regular_countries)
      priority_countries.sort_by! { |country| country[:name] }
      regular_countries.sort_by! { |country| country[:name] }
      priority_countries + regular_countries
    end

    def get_search_priority_countries(request)
      priority_countries = DEFAULT_PRIORITY_COUNTRY_CODES.dup
      return priority_countries unless request

      geo_country_code = get_user_country_code_simple(request)
      priority_countries.prepend(geo_country_code) if geo_country_code && priority_countries.exclude?(geo_country_code)

      priority_countries
    end

    def get_user_country_code_simple(request)
      ip_address = request.remote_ip
      cache_key = "geocoder/country_code/#{ip_address}"

      Rails.cache.fetch(cache_key, expires_in: 24.hours, race_condition_ttl: 10) do
        Geocoder.search(ip_address).first&.country_code
      end
    rescue Geocoder::Error, Timeout::Error
      nil
    end
end
