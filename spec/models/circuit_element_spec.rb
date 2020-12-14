# frozen_string_literal: true

require "rails_helper"


RSpec.describe CircuitElement, type: :model do
  let(:category_list) { ["Input", "Output", "Gates", "Decoders & Plexers",
    "Sequential Elements", "Test Bench", "Misc"] }

  let(:input) { ["Input", "Button", "Power", "Ground", "ConstantVal", "Stepper", "Random",
   "Counter"] }

  let(:output) { ["Output", "RGBLed", "DigitalLed", "VariableLed", "HexDisplay", "SevenSegDisplay",
    "SixteenSegDisplay", "SquareRGBLed", "RGBLedMatrix"] }
  let(:gates) { ["AndGate", "OrGate", "NotGate", "XorGate", "NandGate", "NorGate", "XnorGate"] }

  let(:decoders_and_plexers) { ["Multiplexer", "Demultiplexer", "BitSelector", "MSB", "LSB",
  "PriorityEncoder", "Decoder"] }

  let(:sequential_elements) { ["DflipFlop", "Dlatch", "TflipFlop", "JKflipFlop", "SRflipFlop",
    "TTY", "Keyboard", "Clock", "Rom", "RAM", "EEPROM"] }

  let(:test_bench) { ["TB_Input", "TB_Output", "ForceGate"] }

  let(:misc) { ["Flag", "Splitter", "Adder", "TriState", "Buffer", "ControlledInverter", 
    "ControlledBuffer", "ALU","Rectangle", "Arrow", "Text", "Tunnel"] }

  describe "methods" do
    it "should return category wise element lists" do
      expect(described_class.element_list("Input").sort).to eq(input.sort)
      expect(described_class.element_list("Output").sort).to eq(output.sort)
      expect(described_class.element_list("Gates").sort).to eq(gates.sort)
      expect(described_class.element_list("Decoders & Plexers").sort)
      .to eq(decoders_and_plexers.sort)
      expect(described_class.element_list("Sequential Elements").sort)
      .to eq(sequential_elements.sort)
      expect(described_class.element_list("Test Bench").sort).to eq(test_bench.sort)
      expect(described_class.element_list("Misc").sort).to eq(misc.sort)
    end

    it "returns category list" do
      expect(described_class.category_list.sort).to eq(category_list.sort)
    end
  end
end
