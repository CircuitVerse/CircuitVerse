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
      {
        circuits_count: "1.3M+",
        users_count: "314K+",
        universities_count: "4K+",
        countries_count: "100+"
      }
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
