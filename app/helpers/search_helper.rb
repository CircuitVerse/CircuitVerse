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
      # Cache on the request to avoid repeated geocoding within the same request
      cached = request&.env&.dig("cv.priority_countries")
      return cached if cached

      priority_countries = DEFAULT_PRIORITY_COUNTRY_CODES.dup

      return priority_countries unless request

      country_alpha2 = nil

      begin
        geo_result = nil

        # Prefer request.location if available
        if request.respond_to?(:location)
          begin
            geo_result = request.location
          rescue Geocoder::Error, Timeout::Error
            geo_result = nil
          end
        end

        # Fallback to explicit IP lookup
        if geo_result.nil?
          ip = request.remote_ip rescue nil
          if ip
            geo_result = Geocoder.search(ip).first
          end
        end

        if geo_result
          country_alpha2 = geo_result.respond_to?(:country_code) ? geo_result.country_code : nil
          if country_alpha2.nil? || country_alpha2.to_s.strip.empty?
            country_name = geo_result.respond_to?(:country) ? geo_result.country : nil
            country_alpha2 = normalize_country_to_alpha2(country_name)
          end
        end
      rescue Geocoder::Error, Timeout::Error
        country_alpha2 = nil
      end

      if country_alpha2 && !country_alpha2.to_s.strip.empty?
        code = country_alpha2.to_s.upcase
        priority_countries.prepend(code) unless priority_countries.include?(code)
      end

      # Store in the request env for subsequent calls in the same request
      request.env["cv.priority_countries"] = priority_countries
      priority_countries
    end

    def normalize_country_to_alpha2(country_name)
      return nil if country_name.nil? || country_name.to_s.strip.empty?
      country = ISO3166::Country.find_country_by_name(country_name)
      country&.alpha2
    end
end
