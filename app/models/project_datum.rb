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
  #
  # The rescue is deliberately limited to Redis. On a miss, `Rails.cache.fetch`
  # runs the block first and propagates whatever it raises, so a `StandardError`
  # here would also catch a database timeout from `find_by` and run that same
  # timed-out query a second time -- adding load exactly when Postgres is
  # already struggling, which is the failure this cache exists to prevent.
  #
  # `skip_nil: true` keeps an absent datum out of the cache. Every creation
  # path currently goes through this model, but a read that observes the
  # pre-commit state can write its nil *after* the creating row's
  # `after_commit` has already expired the key -- leaving a nil pinned for the
  # full TTL. A stale nil is also the one bad hit here: 404 for a project that
  # does have data, where a stale non-nil is merely an out-of-date circuit.
  def self.cached_data(project_id)
    Rails.cache.fetch(cache_key(project_id), expires_in: CACHE_TTL, skip_nil: true) do
      find_by(project_id: project_id)&.data
    end
  rescue Redis::BaseError => e
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
