require 'rspec'
require_relative '../lib/yosys2digitaljs/converter'

RSpec.describe Yosys2Digitaljs::Converter do
  # Fixture: Simple circuit "module top(output y); assign y = 1; endmodule"
  let(:json_input) do
    {
      "modules" => {
        "top" => {
          "attributes" => { "top" => 1 },
          "ports" => {
            "y" => { "direction" => "output", "bits" => [2] }
          },
          "cells" => {
            "$auto$const_1" => {
              "type" => "$constant",
              "parameters" => { "WIDTH" => 1 },
              "attributes" => {},
              "port_directions" => { "Y" => "output" },
              "connections" => { "Y" => [2] }
            }
          },
          "netnames" => {
            "y" => { "bits" => [2], "attributes" => {} }
          }
        }
      }
    }
  end

  subject { described_class.new(json_input) }

  describe '#convert' do
    let(:result) { subject.convert }
    let(:devices) { result[:devices] }
    let(:connectors) { result[:connectors] }

    it 'creates an output device' do
      # We expect a device with label 'y' and type 'Output'
      output_dev = devices.values.find { |d| d['label'] == 'y' }
      expect(output_dev).not_to be_nil
      # IoUiProcessor converts 1-bit Output to Lamp
      expect(output_dev['type']).to eq('Lamp')
    end

    it 'creates a constant device' do
      # We expect a device with type 'Constant'
      const_dev = devices.values.find { |d| d['type'] == 'Constant' }
      expect(const_dev).not_to be_nil
    end

    it 'wires them together' do
      # Net '2' connects Constant(Y) -> Output(in)
      
      expect(connectors.size).to eq(1)
      c = connectors.first
      
      # Determine IDs
      output_id = devices.key(devices.values.find { |d| d['label'] == 'y' })
      const_id = devices.key(devices.values.find { |d| d['type'] == 'Constant' })
      
      expect(c['from']['id']).to eq(const_id)
      expect(c['to']['id']).to eq(output_id)

    end
  end
end
