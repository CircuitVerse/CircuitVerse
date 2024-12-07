# frozen_string_literal: true

class CircuitverseController < ApplicationController
  MAXIMUM_FEATURED_CIRCUITS = 3

  def index
    @projects_paginator = Project.select(:id, :author_id, :image_preview, :name, :slug)
                                 .public_and_not_forked
                                 .where.not(image_preview: "default.png")
                                 .includes(:author)
                                 .cursor_paginate(
                                   order: { id: :desc },
                                   limit: Project.per_page,
                                   after: valid_cursor?(params[:after]) ? params[:after] : nil,
                                   before: valid_cursor?(params[:before]) ? params[:before] : nil
                                 )
    begin
      # Fetch the page of results from the paginator
      @projects_page = @projects_paginator.fetch
      # Extract the records for iteration in the view
      @projects = @projects_page.records
    rescue ActiveRecordCursorPaginate::InvalidCursorError => e
      # Log the error for debugging purposes
      Rails.logger.error("Invalid cursor detected: #{params[:after] || params[:before]} - #{e.message}")
      # Redirect to the root page with an alert
      redirect_to root_path, alert: "Invalid cursor parameter. Returning to the first page."
      return
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

    # Validate the format of the cursor parameter to prevent errors or misuse
    # @param cursor [String, nil] The cursor value to validate
    # @return [Boolean] true if the cursor is valid, false otherwise
    # @note Cursors should be base64-encoded strings containing only alphanumeric characters,
    #       hyphens, and underscores, with a maximum length of 64 characters.
    def valid_cursor?(cursor)
      return false if cursor.blank? || cursor.length > 64

      cursor.match?(/\A[A-Za-z0-9\-_]{1,64}\z/)
    end
end
