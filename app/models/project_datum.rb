# frozen_string_literal: true

class ProjectDatum < ApplicationRecord
  belongs_to :project

  # Circuit data is a large JSON blob that is re-read on every simulator
  # load, embed and API poll, but only changes when a circuit is saved.
  # Serving those reads straight from Postgres on every hit was tripping
  # `statement_timeout` in production (Sentry CIRCUITVERSE-CORE-15D, #7927).
  #
  # Invalidation lives on the model rather than in the controllers because
  # circuit data is written from six different places -- the API create and
  # update_circuit actions, the simulator actions, LTI launch, assignment
  # project creation, and the in-place rename in ProjectsController#update --
  # and `after_commit` catches all of them, including the paths that mutate
  # `.data` without going through a dedicated endpoint.
  CACHE_TTL = 15.minutes

  def self.cache_key(project_id)
    "project_datum/#{project_id}"
  end

  # Returns the raw JSON string, or nil when the project has no circuit data.
  #
  # Falls back to the database if the cache is unavailable: Redis being down
  # must not take a public read endpoint with it.
  def self.cached_data(project_id)
    Rails.cache.fetch(cache_key(project_id), expires_in: CACHE_TTL) do
      find_by(project_id: project_id)&.data
    end
  rescue StandardError => e
    Rails.logger.warn("[ProjectDatum] circuit data cache unavailable, falling back to DB: #{e.class}: #{e.message}")
    find_by(project_id: project_id)&.data
  end

  after_commit :expire_circuit_data_cache

  private

    def expire_circuit_data_cache
      Rails.cache.delete(self.class.cache_key(project_id))
    rescue StandardError => e
      # A stale entry bounded by CACHE_TTL beats a failed save.
      Rails.logger.warn("[ProjectDatum] could not expire circuit data cache: #{e.class}: #{e.message}")
    end
end
