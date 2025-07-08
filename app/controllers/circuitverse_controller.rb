# frozen_string_literal: true

class CircuitverseController < ApplicationController
  def index
    # Cache statistics for 10 minutes to avoid expensive queries on each page load
    @stats = Rails.cache.fetch("homepage_stats", expires_in: 10.minutes) do
      {
        circuits_count: Project.count,
        users_count: User.count,
        universities_count: User.where.not(educational_institute: [nil, ""]).distinct.count(:educational_institute),
        countries_count: User.where.not(country: [nil, ""]).distinct.count(:country)
      }
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
end
