# frozen_string_literal: true

class Api::V1::ReleasesController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:index]

  # GET /api/v1/releases
  def index
    releases_data = fetch_releases_data
    
    render json: {
      circuitverse: releases_data[:circuitverse],
      vue_simulator: releases_data[:vue_simulator],
      last_updated: releases_data[:last_updated],
      total_releases: releases_data[:total_releases]
    }
  end

  # GET /api/v1/releases/circuitverse
  def circuitverse
    releases = fetch_circuitverse_releases
    render json: releases
  end

  # GET /api/v1/releases/vue-simulator
  def vue_simulator
    releases = fetch_vue_simulator_releases
    render json: releases
  end

  private

  def fetch_releases_data
    circuitverse_releases = fetch_circuitverse_releases
    vue_simulator_releases = fetch_vue_simulator_releases
    
    {
      circuitverse: circuitverse_releases,
      vue_simulator: vue_simulator_releases,
      last_updated: Time.current.strftime('%Y-%m-%dT%H:%M:%SZ'),
      total_releases: circuitverse_releases.length + vue_simulator_releases.length
    }
  end

  def fetch_circuitverse_releases
    cache_key = 'circuitverse_releases'
    
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      fetch_github_releases('CircuitVerse', 'CircuitVerse')
    end
  end

  def fetch_vue_simulator_releases
    cache_key = 'vue_simulator_releases'
    
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      fetch_github_releases('CircuitVerse', 'cv-frontend-vue')
    end
  end

  def fetch_github_releases(owner, repo)
    begin
      response = HTTParty.get(
        "https://api.github.com/repos/#{owner}/#{repo}/releases",
        headers: {
          'Accept' => 'application/vnd.github.v3+json',
          'User-Agent' => 'CircuitVerse-API',
          'Authorization' => "token #{Rails.application.credentials.github_token}"
        }
      )
      
      if response.success?
        releases = JSON.parse(response.body)
        releases.map do |release|
          {
            tag_name: release['tag_name'],
            name: release['name'],
            published_at: release['published_at'],
            html_url: release['html_url'],
            prerelease: release['prerelease'],
            draft: release['draft']
          }
        end
      else
        Rails.logger.error "Failed to fetch releases for #{owner}/#{repo}: #{response.code}"
        []
      end
    rescue StandardError => e
      Rails.logger.error "Error fetching releases for #{owner}/#{repo}: #{e.message}"
      []
    end
  end
end
