# frozen_string_literal: true

class CircuitverseController < ApplicationController
  MAXIMUM_FEATURED_CIRCUITS = 3

  def index
    @projects_paginator = build_projects_query
    @projects_page = @projects_paginator.fetch
  rescue ActiveRecordCursorPaginate::InvalidCursorError => e
    Rails.logger.warn "Invalid cursor detected: #{e.message}. Falling back to initial page."
    flash.now[:alert] = "Invalid page parameter. Showing first page."
    @projects_paginator = build_projects_query(skip_cursor: true)
    @projects_page = @projects_paginator.fetch
  ensure
    @projects = @projects_page&.records || []

    @featured_circuits = Project.joins(:featured_circuit)
                                .order("featured_circuits.created_at DESC")
                                .includes(:author, circuit_preview_attachment: :blob)
                                .limit(MAXIMUM_FEATURED_CIRCUITS)

    respond_to do |format|
      format.html
      format.json { render json: @projects }
      format.js
    end
  end

  def examples
    @examples = [{ name: "Full Adder from 2-Half Adders", id: "users/3/projects/247",
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
                   img: "examples/ALU_n.jpg" }]
  end

  def tos; end

  def teachers; end

  def contribute; end

  private

    # Builds the cursor-paginated, eager-loaded query for the landing-page carousel.
    def build_projects_query(skip_cursor: false)
      query = Project
              .select(:id, :author_id, :image_preview, :name, :slug)
              .public_and_not_forked
              .where.not(image_preview: "default.png")
              .with_attached_circuit_preview
              .includes(:author)

      cursor_params = {
        order: { id: :desc },
        limit: Project.per_page
      }

      unless skip_cursor
        cursor_params[:after] = params[:after]
        cursor_params[:before] = params[:before]
      end

      # Use ** to pass the hash as keyword arguments
      query.cursor_paginate(**cursor_params)
    end
end
