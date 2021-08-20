# frozen_string_literal: true

class LogixController < ApplicationController
  MAXIMUM_FEATURED_CIRCUITS = 3

  def index
    @projects = Project.select(:id, :author_id, :image_preview, :name, :slug)
                       .public_and_not_forked
                       .where.not(image_preview: "default.png")
                       .order(id: :desc)
                       .includes(:author)
                       .limit(Project.per_page)

    page = params[:page].to_i
    @projects = if page.positive?
      @projects.paginate(page: page)
    else
      @projects.paginate(page: nil)
    end

    @featured_circuits = Project.joins(:featured_circuit)
                                .order("featured_circuits.created_at DESC")
                                .includes(:author)
                                .limit(MAXIMUM_FEATURED_CIRCUITS)

    respond_to do |format|
      format.html
      format.json { render json: @projects }
      format.js
    end
  end

  def examples
    @examples = [{ name: t("logix.examples.example1"), id: "users/3/projects/247",
                   img: "examples/fullAdder_n.jpg" },
                 { name: t("logix.examples.example2"), id: "users/3/projects/248",
                   img: "examples/RippleCarry_n.jpg" },
                 { name: t("logix.examples.example3"), id: "users/3/projects/249",
                   img: "examples/AsyncCounter_n.jpg" },
                 { name: t("logix.examples.example4"), id: "users/3/projects/250",
                   img: "examples/Keyboard_n.jpg" },
                 { name: t("logix.examples.example5"), id: "users/3/projects/251",
                   img: "examples/FlipFlop_n.jpg" },
                 { name: t("logix.examples.example6"), id: "users/126/projects/252",
                   img: "examples/ALU_n.jpg" }]
  end

  def tos; end

  def teachers; end

  def contribute; end
end
