# frozen_string_literal: true

class ExploreController < ApplicationController
  MAX_TAGS          = 30
  RECENT_LIMIT      = Project.per_page
  EDITOR_PICKS_MAX  = 12

  def index
    @circuit_of_the_week = circuit_of_the_week
    @editor_picks        = editor_picks
    @recent_projects     = recent_projects
    @top_tags            = top_tags
    @examples            = featured_examples_static
  end

  private

  def circuit_of_the_week
    Project
      .joins(:featured_circuit)
      .includes(:author, :stars)
      .order("featured_circuits.created_at DESC")
      .limit(1)
      .first || Project.open
                       .where("projects.updated_at >= ?", 1.week.ago)
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

  def recent_projects
    Project.select(:id, :author_id, :image_preview, :name, :slug, :view, :description)
           .public_and_not_forked
           .where.not(image_preview: "default.png")
           .includes(:author, :stars)
           .order(id: :desc)
           .limit(RECENT_LIMIT)
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
