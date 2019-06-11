CIRCUIT_ELEMENTS = {
  "Input": [
    { name: "Input" },
    { name: "Button" },
    { name: "Power" },
    { name: "Ground" },
    { name: "ConstantVal" },
    { name: "Stepper" },
    { name: "Random" },
    { name: "Counter" }
  ],
  "Output": [
    { name: "Output" },
    { name: "RGBLed" },
    { name: "DigitalLed" },
    { name: "VariableLed" },
    { name: "HexDisplay" },
    { name: "SevenSegDisplay" },
    { name: "SixteenSegDisplay" },
    { name: "SquareRGBLed" },
    { name: "RGBLedMatrix" },
  ],
  "Gates": [
    { name: "AndGate" },
    { name: "OrGate" },
    { name: "NotGate" },
    { name: "XorGate" },
    { name: "NandGate" },
    { name: "NorGate" },
    { name: "XnorGate" }
  ],
  "Decoders & Plexers": [
    { name: "Multiplexer" },
    { name: "Demultiplexer" },
    { name: "BitSelector" },
    { name: "MSB" },
    { name: "LSB" },
    { name: "PriorityEncoder" },
    { name: "Decoder" },
  ],
  "Sequential Elements": [
    { name: "DflipFlop" },
    { name: "Dlatch" },
    { name: "TflipFlop" },
    { name: "JKflipFlop" },
    { name: "SRflipFlop" },
    { name: "TTY" },
    { name: "Keyboard" },
    { name: "Clock" },
    { name: "Rom" },
    { name: "RAM" },
    { name: "EEPROM" },
  ],
  "Test Bench": [
    { name: "TB_Input" },
    { name: "TB_Output" },
    { name: "ForceGate" },
  ],
  "Misc": [
    { name: "Flag" },
    { name: "Splitter" },
    { name: "Adder" },
    { name: "TriState" },
    { name: "Buffer" },
    { name: "ControlledInverter" },
    { name: "ALU" },
    { name: "Rectangle" },
    { name: "Arrow" },
    { name: "Text" },
    { name: "Tunnel" },

  ]
}

CIRCUIT_ELEMENTS.each do |category, elements|
  puts "Seeding category: #{category}"
  elements.each do |element|
    puts "\t Seeding #{element[:name]}"
    ActiveRecord::Base.transaction do
      circuit_element = CircuitElement.find_or_create_by(name: element[:name])
      circuit_element.category = category
      circuit_element.name = element[:name]
      circuit_element.image = File.new(Rails.root.join("public/img/#{element[:name]}.svg"))
      circuit_element.save!
    end
  end
end





