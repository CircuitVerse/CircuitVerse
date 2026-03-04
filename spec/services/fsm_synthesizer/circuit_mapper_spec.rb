require 'rails_helper'

RSpec.describe FsmSynthesizer::CircuitMapper do
  let(:fsm) do
    f = FsmSynthesizer::Base.new(
      machine_type: :moore,
      inputs: ['0', '1'],
      outputs: ['y'],
      states: [{ id: 'S0', initial: true }, { id: 'S1' }],
      transitions: [
        { from: 'S0', input: '0', to: 'S0' },
        { from: 'S0', input: '1', to: 'S1' },
        { from: 'S1', input: '0', to: 'S1' },
        { from: 'S1', input: '1', to: 'S0' }
      ],
      state_outputs: { 'S0' => 'y', 'S1' => 'y' }
    )
    FsmSynthesizer::Encoder.encode_binary(f)
    FsmSynthesizer::EquationGenerator.generate_next_state_equations(f)
    FsmSynthesizer::EquationGenerator.generate_output_equations(f)
    f
  end

  describe '.generate_circuit' do
    it 'generates circuit representation' do
      circuit = FsmSynthesizer::CircuitMapper.generate_circuit(fsm)
      expect(circuit).to have_key(:metadata)
      expect(circuit).to have_key(:components)
      expect(circuit).to have_key(:connections)
    end

    it 'includes FSM metadata' do
      circuit = FsmSynthesizer::CircuitMapper.generate_circuit(fsm)
      expect(circuit[:metadata][:machine_type]).to eq(:moore)
      expect(circuit[:metadata][:states]).to eq(2)
    end

    it 'generates flip-flop components' do
      circuit = FsmSynthesizer::CircuitMapper.generate_circuit(fsm)
      flops = circuit[:components][:flip_flops]
      expect(flops.size).to eq(1) # 1 state bit
      expect(flops[0][:type]).to eq('dflipflop')
    end

    it 'generates gate components' do
      circuit = FsmSynthesizer::CircuitMapper.generate_circuit(fsm)
      gates = circuit[:components][:gates]
      expect(gates.size).to be > 0
    end
  end
end
