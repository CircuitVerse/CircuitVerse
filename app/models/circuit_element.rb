# frozen_string_literal: true

class CircuitElement < ApplicationRecord
  has_and_belongs_to_many :assignments

  enum category: ["Input", "Output", "Gates", "Decoders & Plexers", "Sequential Elements",
    "Test Bench", "Misc"]

  mount_uploader :image, CircuitElementsImageUploader

  CATEGORY_LIST = ["Input", "Output", "Gates", "Decoders & Plexers",
    "Sequential Elements", "Test Bench", "Misc"]

  INPUT = ["Input", "Button", "Power", "Ground", "ConstantVal", "Stepper", "Random", "Counter"]

  OUTPUT = ["Output", "RGBLed", "DigitalLed", "VariableLed", "HexDisplay", "SevenSegDisplay",
    "SixteenSegDisplay", "SquareRGBLed", "RGBLedMatrix"]
  GATES = ["AndGate", "OrGate", "NotGate", "XorGate", "NandGate", "NorGate", "XnorGate"]

  DECODERS_AND_PLEXERS = ["Multiplexer", "Demultiplexer", "BitSelector", "MSB", "LSB",
  "PriorityEncoder", "Decoder"]

  SEQUENTIAL_ELEMENTS = ["DflipFlop", "Dlatch", "TflipFlop", "JKflipFlop", "SRflipFlop", "TTY",
    "Keyboard", "Clock", "Rom", "RAM", "EEPROM"]

  TEST_BENCH = ["TB_Input", "TB_Output", "ForceGate"]

  MISC = ["Flag", "Splitter", "Adder", "TriState", "Buffer", "ControlledInverter", "ALU",
   "Rectangle", "Arrow", "Text", "Tunnel"]


  def self.element_list(category)
    case category
    when "Input"
      INPUT
    when "Output"
      OUTPUT
    when "Gates"
      GATES
    when "Decoders & Plexers"
      DECODERS_AND_PLEXERS
    when "Sequential Elements"
      SEQUENTIAL_ELEMENTS
    when "Test Bench"
      TEST_BENCH
    when "Misc"
      MISC
    end
  end

  def self.category_list
    CATEGORY_LIST
  end

  def self.all_element_list
    CATEGORY_LIST.reduce([]) do |l, c|
        l += element_list(c)
        l
      end
  end
end
