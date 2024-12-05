# frozen_string_literal: true

class CircuitverseController < ApplicationController
  MAXIMUM_FEATURED_CIRCUITS = 3

  include ActionView::Helpers::AssetUrlHelper
  include ActionView::Helpers::AssetTagHelper

  def index
    per_page = params.fetch(:per_page, 10).to_i
    cursor = params[:cursor]

    @projects = Project.select(:id, :author_id, :image_preview, :name, :slug)
                       .public_and_not_forked
                       .where.not(image_preview: "default.png")
                       .includes(:author)
                       .order(id: :desc)

    # Apply cursor-based pagination using the gem
    paginator = @projects.cursor_paginate(after: cursor, limit: per_page)
    page = paginator.fetch
    @projects = page.records

    # Determine if there's a next or previous cursor
    @next_cursor = page.next_cursor
    @previous_cursor = page.previous_cursor

    @featured_circuits = Project.joins(:featured_circuit)
                                .order("featured_circuits.created_at DESC")
                                .includes(:author)
                                .limit(MAXIMUM_FEATURED_CIRCUITS)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          projects: @projects.map { |project| serialize_project(project) },
          next_cursor: @next_cursor
        }
      end
      format.js
    end
  end

  def examples
    @examples = [
      {
        name: "Full Adder from 2-Half Adders",
        id: "users/3/projects/247",
        img: "examples/fullAdder_n.jpg"
      },
      {
        name: "16 Bit ripple carry adder",
        id: "users/3/projects/248",
        img: "examples/RippleCarry_n.jpg"
      },
      {
        name: "Asynchronous Counter",
        id: "users/3/projects/249",
        img: "examples/AsyncCounter_n.jpg"
      },
      {
        name: "Keyboard",
        id: "users/3/projects/250",
        img: "examples/Keyboard_n.jpg"
      },
      {
        name: "FlipFlop",
        id: "users/3/projects/251",
        img: "examples/FlipFlop_n.jpg"
      },
      {
        name: "ALU 74LS181 by Ananth Shreekumar",
        id: "users/126/projects/252",
        img: "examples/ALU_n.jpg"
      }
    ]
  end

  def tos; end

  def teachers; end

  def contribute; end

  private

  def serialize_project(project)
    {
      id: project.id,
      author_id: project.author_id,
      name: project.name,
      slug: project.slug,
      image_preview: project_image_preview(project)
    }
  end

  def project_image_preview(project)
    if project.image_preview.present? && project.image_preview.url != "/uploads/project/image_preview/default.png"
      project.image_preview.url
    else
      asset_path("default.png")
    end
  end
end
