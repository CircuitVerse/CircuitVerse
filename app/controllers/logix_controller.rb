# frozen_string_literal: true

class LogixController < ApplicationController
  # before_action :authenticate_user!

  MAXIMUM_FEATURED_CIRCUITS = 4

  def index
    @projects = Project.select("id,author_id,image_preview,name")
                       .where(project_access_type: "Public", forked_project_id: nil)
                       .paginate(page: params[:page]).order("id desc").limit(Project.per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
      format.js
    end

    @featured_circuits = Project.joins(:featured_circuit).order("featured_circuits.created_at DESC")
                                .limit(MAXIMUM_FEATURED_CIRCUITS)
  end

  def gettingStarted; end

  def examples
    @examples = [{ name: "Full Adder from 2-Half Adders", id: "users/3/projects/247",
                   img: "examples/fullAdder_n.png" },
                 { name: "16 Bit ripple carry adder", id: "users/3/projects/248",
                   img: "examples/RippleCarry_n.jpg" },
                 { name: "Asynchronous Counter", id: "users/3/projects/249",
                   img: "examples/AsyncCounter_n.jpg" },
                 { name: "Keyboard", id: "users/3/projects/250",
                   img: "examples/Keyboard_n.jpg" },
                 { name: "FlipFlop", id: "users/3/projects/251",
                   img: "examples/FlipFlop_n.jpg" },
                 { name: "ALU 74LS181 by Ananth Shreekumar", id: "users/3/projects/252",
                   img: "examples/ALU_n.png" }]
  end

  def features; end

  def all_user_index; end

  def tos; end

  def teachers; end

  def contribute; end
end
