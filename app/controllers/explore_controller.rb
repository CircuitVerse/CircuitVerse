# frozen_string_literal: true

class ExploreController < ApplicationController
  before_action :redirect_unless_enabled!

  MAX_TAGS          = 30
  RECENT_LIMIT      = 12
  EDITOR_PICKS_MAX  = 12

  def index
    redirect_to explore_path(section: "picks") and return if params[:section] == "examples"

    @circuit_of_the_week = circuit_of_the_week
    @editor_picks        = editor_picks
    load_recent_projects_with_cursor!
    @top_tags = top_tags
  end

  private

    def redirect_unless_enabled!
      return if Flipper.enabled?(:circuit_explore_page, current_user)

      redirect_to root_path and return
    end

    def circuit_of_the_week
      Project
        .joins(:featured_circuit)
        .includes(:author, :stars)
        .order("featured_circuits.created_at DESC")
        .limit(1)
        .first || Project.open
                         .where(projects: { updated_at: 1.week.ago.. })
                         .includes(:author, :stars)
                         .order(view: :desc, id: :desc)
                         .limit(1)
                         .first
    end

    def editor_picks
      Project.joins(:featured_circuit)
             .includes(:author, :stars)
             .order("featured_circuits.created_at DESC")
             .limit(EDITOR_PICKS_MAX)
    end

    # rubocop:disable Metrics/MethodLength
    def load_recent_projects_with_cursor!
      paginator = build_recent_paginator
      page = paginator.fetch

      @recent_projects = page.records

      @has_prev_recent   = page.has_previous?
      @has_next_recent   = page.has_next?
      @recent_prev_cursor = page.previous_cursor
      @recent_next_cursor = page.next_cursor
    rescue ActiveRecordCursorPaginate::InvalidCursorError => e
      Rails.logger.warn "Explore invalid cursor: #{e.message}. Falling back to first page."
      paginator = build_recent_paginator(skip_cursor: true)
      page = paginator.fetch

      @recent_projects    = page.records
      @has_prev_recent    = page.has_previous?
      @has_next_recent    = page.has_next?
      @recent_prev_cursor = page.previous_cursor
      @recent_next_cursor = page.next_cursor
    end
    # rubocop:enable Metrics/MethodLength

    def build_recent_paginator(skip_cursor: false)
      relation = recent_base_scope

      params_hash = {
        order: { id: :desc },
        limit: RECENT_LIMIT
      }

      unless skip_cursor
        params_hash[:after]  = params[:after]
        params_hash[:before] = params[:before]
      end

      relation.cursor_paginate(**params_hash)
    end

    def recent_base_scope
      Project.select(:id, :author_id, :image_preview, :name, :slug, :view, :description)
             .public_and_not_forked
             .includes(:author, :stars)
    end

    def top_tags
      Rails.cache.fetch("explore/top_tags:v1:limit=#{MAX_TAGS}", expires_in: 5.hours, race_condition_ttl: 10) do
        Tag
          .joins(:projects)
          .merge(Project.open)
          .group("tags.id")
          .order(Arel.sql("COUNT(taggings.id) DESC"))
          .limit(MAX_TAGS)
          .select(:id, :name)
          .to_a
      end
    end
end
