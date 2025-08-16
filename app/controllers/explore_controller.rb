# frozen_string_literal: true

class ExploreController < ApplicationController
  before_action :redirect_unless_enabled!

  MAX_TAGS          = 30
  RECENT_LIMIT      = 12
  EDITOR_PICKS_MAX  = 12

  def index
    @circuit_of_the_week = circuit_of_the_week
    @editor_picks        = editor_picks
    load_recent_projects_with_cursor!
    @top_tags            = top_tags
    @examples            = featured_examples_static
  end

  private

    def redirect_unless_enabled!
      return if Flipper.enabled?(:circuit_explore_page, current_user)

      redirect_to root_path
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
      Tag.joins(:projects)
         .merge(Project.open)
         .group("tags.id")
         .order(Arel.sql("COUNT(taggings.id) DESC"))
         .limit(MAX_TAGS)
    end

    def featured_examples_static
      [
        { name: "Full Adder from 2-Half Adders", id: "users/3/projects/247",
          img: "examples/fullAdder_n.jpg" },
        { name: "16 Bit ripple carry adder", id: "users/3/projects/248",
          img: "examples/RippleCarry_n.jpg" },
        { name: "Asynchronous Counter", id: "users/3/projects/249",
          img: "examples/AsyncCounter_n.jpg" },
        { name: "Keyboard", id: "users/3/projects/250",
          img: "examples/Keyboard_n.jpg" },
        { name: "FlipFlop", id: "users/3/projects/251",
          img: "examples/FlipFlop_n.jpg" },
        { name: "ALU 74LS181 by Ananth Shreekumar", id: "users/126/projects/252",
          img: "examples/ALU_n.jpg" }
      ]
    end
end
