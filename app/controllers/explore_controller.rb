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
      base = recent_base_scope

      if params[:before_id].present?
        records = base.where(Project.arel_table[:id].lt(params[:before_id].to_i))
                      .order(id: :desc)
                      .limit(RECENT_LIMIT)
                      .to_a
      elsif params[:after_id].present?
        newer = base.where(Project.arel_table[:id].gt(params[:after_id].to_i))
                    .order(id: :asc)
                    .limit(RECENT_LIMIT)
                    .to_a
        records = newer.reverse
      else
        records = base.order(id: :desc).limit(RECENT_LIMIT).to_a
      end

      @recent_projects = records

      if @recent_projects.any?
        first_id = @recent_projects.first.id
        last_id  = @recent_projects.last.id

        @has_prev_recent = base.exists?(["projects.id > ?", first_id])
        @has_next_recent = base.exists?(["projects.id < ?", last_id])

        @recent_prev_after_id  = first_id
        @recent_next_before_id = last_id
      else
        @has_prev_recent = false
        @has_next_recent = false
        @recent_prev_after_id  = nil
        @recent_next_before_id = nil
      end
    end
    # rubocop:enable Metrics/MethodLength

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
