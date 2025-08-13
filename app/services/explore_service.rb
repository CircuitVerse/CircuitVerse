# frozen_string_literal: true

class ExploreService
  DEFAULT_RECENT_PER_PAGE = 9
  EDITOR_PICKS_LIMIT = 6
  TAGS_LIMIT = 20

  def initialize(current_user:, params:)
    @current_user = current_user
    @params = params
  end

  def circuit_of_the_week
    week_ago = 1.week.ago

    top = Project.public_and_not_forked
                 .open
                 .left_joins(:stars)
                 .where("stars.created_at >= ?", week_ago)
                 .group("projects.id")
                 .order(Arel.sql("COUNT(stars.id) DESC"), created_at: :desc)
                 .includes(:author)
                 .limit(1)
                 .first
    return top if top

    Project.public_and_not_forked
           .open
           .order(view: :desc, created_at: :desc)
           .includes(:author)
           .limit(1)
           .first
  end

  def featured_examples
    [
      { name: "Full Adder from 2-Half Adders", id: "users/3/projects/247", img: "examples/fullAdder_n.jpg" },
      { name: "16 Bit ripple carry adder",     id: "users/3/projects/248", img: "examples/RippleCarry_n.jpg" },
      { name: "Asynchronous Counter",          id: "users/3/projects/249", img: "examples/AsyncCounter_n.jpg" },
      { name: "Keyboard",                      id: "users/3/projects/250", img: "examples/Keyboard_n.jpg" },
      { name: "FlipFlop",                      id: "users/3/projects/251", img: "examples/FlipFlop_n.jpg" },
      { name: "ALU 74LS181 by Ananth Shreekumar", id: "users/126/projects/252", img: "examples/ALU_n.jpg" }
    ]
  end

  def editor_picks
    Project.joins(:featured_circuit)
           .order("featured_circuits.created_at DESC")
           .includes(:author)
           .limit(EDITOR_PICKS_LIMIT)
  end

  def recent_projects
    relation = Project.select(:id, :author_id, :image_preview, :name, :slug, :description, :view, :project_access_type, :created_at)
                      .public_and_not_forked
                      .where.not(image_preview: "default.png")
                      .includes(:author)
                      .order(created_at: :desc, id: :desc)

    per_page = (@params[:per_page] || DEFAULT_RECENT_PER_PAGE).to_i
    page     = (@params[:page] || 1).to_i
    relation.paginate(page: page, per_page: per_page)
  end

  def popular_tags
    Tag.joins(:taggings)
       .group("tags.id")
       .order(Arel.sql("COUNT(taggings.id) DESC"))
       .limit(TAGS_LIMIT)
       .select("tags.*, COUNT(taggings.id) AS tags_count")
  end
end
