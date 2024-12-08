# frozen_string_literal: true

class CircuitverseController < ApplicationController
  MAXIMUM_FEATURED_CIRCUITS = 3

  def index
    @projects = fetch_projects
    @featured_circuits = fetch_featured_circuits

    respond_to do |format|
      format.html
      format.json { render json: @projects }
      format.js
    end
  end

  def examples
    @examples = [
      { name: "Full Adder from 2-Half Adders", id: "users/3/projects/247", img: "examples/fullAdder_n.jpg" },
      { name: "16 Bit ripple carry adder", id: "users/3/projects/248", img: "examples/RippleCarry_n.jpg" },
      { name: "Asynchronous Counter", id: "users/3/projects/249", img: "examples/AsyncCounter_n.jpg" },
      { name: "Keyboard", id: "users/3/projects/250", img: "examples/Keyboard_n.jpg" },
      { name: "FlipFlop", id: "users/3/projects/251", img: "examples/FlipFlop_n.jpg" },
      { name: "ALU 74LS181 by Ananth Shreekumar", id: "users/126/projects/252", img: "examples/ALU_n.jpg" }
    ]
  end

  def tos; end

  def teachers; end

  def contribute; end

  private

    # Fetch paginated projects
    def fetch_projects
      paginator = Project.select(:id, :author_id, :image_preview, :name, :slug)
                         .public_and_not_forked
                         .where.not(image_preview: "default.png")
                         .includes(:author)
                         .cursor_paginate(
                           order: { id: :desc },
                           limit: Project.per_page,
                           after: valid_cursor?(params[:after]) ? params[:after] : nil,
                           before: valid_cursor?(params[:before]) ? params[:before] : nil
                         )
      fetch_paginated_results(paginator)
    end

    # Fetch featured circuits
    def fetch_featured_circuits
      Project.joins(:featured_circuit)
             .order("featured_circuits.created_at DESC")
             .includes(:author)
             .limit(MAXIMUM_FEATURED_CIRCUITS)
    end

    # Fetch paginated results with error handling
    def fetch_paginated_results(paginator)
      @projects_page = paginator.fetch # Assign the paginator object to @projects_page
      @projects_page.records           # Return the records for rendering
    rescue ActiveRecordCursorPaginate::InvalidCursorError => e
      handle_invalid_cursor_error(e)
    end

    # Handle invalid cursor errors
    def handle_invalid_cursor_error(error)
      Rails.logger.error("Invalid cursor detected: #{params[:after] || params[:before]} - #{error.message}")
      redirect_to root_path, alert: "Invalid cursor parameter. Returning to the first page." and return
      []
    end

    # Validate the format of the cursor parameter to prevent errors or misuse
    # @param cursor [String, nil] The cursor value to validate
    # @return [Boolean] true if the cursor is valid, false otherwise
    # @note Cursors should be base64-encoded strings containing only alphanumeric characters,
    #       hyphens, underscores, and equal signs for padding, with a maximum length of 64 characters.
    def valid_cursor?(cursor)
      return false if cursor.blank? || cursor.length > 64

      cursor.match?(/\A[A-Za-z0-9\-_=]{1,64}\z/)
    end
end
