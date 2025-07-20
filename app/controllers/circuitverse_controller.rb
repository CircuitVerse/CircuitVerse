# frozen_string_literal: true

class CircuitverseController < ApplicationController
  before_action :set_homepage_data, only: [:index]

  def index; end

  def examples
    @examples = example_projects
  end

  def tos; end

  def teachers; end

  def contribute; end

  private

    def set_homepage_data
      @stats = fetch_homepage_statistics
      @features = feature_data
    end

    def fetch_homepage_statistics
      Rails.cache.fetch("homepage_stats", expires_in: cache_duration) do
        calculate_statistics
      end
    rescue StandardError => e
      Rails.logger.error "Homepage stats calculation failed: #{e.message}"
      default_statistics
    end

    def calculate_statistics
      {
        circuits_count: Project.count,
        users_count: User.count,
        universities_count: User.distinct.where.not(educational_institute: [nil, ""]).count(:educational_institute),
        countries_count: User.distinct.where.not(country: [nil, ""]).count(:country)
      }
    end

    def cache_duration
      Rails.env.production? ? 10.minutes : 1.minute
    end

    def default_statistics
      { circuits_count: 0, users_count: 0, universities_count: 0, countries_count: 0 }
    end

    def feature_data
      [
        {
          image_path: "homepage/export-hd.png",
          alt_text: "Export HD",
          title_key: "circuitverse.index.features.item1_heading",
          description_key: "circuitverse.index.features.item1_text"
        },
        {
          image_path: "homepage/combinations analysis.png",
          alt_text: "Combinational Analysis",
          title_key: "circuitverse.index.features.item2_heading",
          description_key: "circuitverse.index.features.item2_text"
        },
        {
          image_path: "homepage/testbench-timing-diagram.png",
          alt_text: "Testbench Timing Diagram",
          title_key: "circuitverse.index.features.item3_heading",
          description_key: "circuitverse.index.features.item3_text"
        },
        {
          image_path: "homepage/embed.png",
          alt_text: "Embed",
          title_key: "circuitverse.index.features.item4_heading",
          description_key: "circuitverse.index.features.item4_text"
        },
        {
          image_path: "homepage/sub-circuit.png",
          alt_text: "Sub Circuit",
          title_key: "circuitverse.index.features.item5_heading",
          description_key: "circuitverse.index.features.item5_text"
        },
        {
          image_path: "homepage/multi-bit-bus.png",
          alt_text: "Multi Bit Bus",
          title_key: "circuitverse.index.features.item6_heading",
          description_key: "circuitverse.index.features.item6_text"
        }
      ]
    end

    def example_projects
      [
        { name: "Full Adder from 2-Half Adders", id: "users/3/projects/247", img: "examples/fullAdder_n.jpg" },
        { name: "16 Bit ripple carry adder", id: "users/3/projects/248", img: "examples/RippleCarry_n.jpg" },
        { name: "Asynchronous Counter", id: "users/3/projects/249", img: "examples/AsyncCounter_n.jpg" },
        { name: "Keyboard", id: "users/3/projects/250", img: "examples/Keyboard_n.jpg" },
        { name: "FlipFlop", id: "users/3/projects/251", img: "examples/FlipFlop_n.jpg" },
        { name: "ALU 74LS181 by Ananth Shreekumar", id: "users/126/projects/252", img: "examples/ALU_n.jpg" }
      ]
    end
end
