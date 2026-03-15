require 'rails_helper'

RSpec.describe FsmSynthesizer::EquationGenerator do
  describe '.generate_next_state_equations' do
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
      f
    end

    it 'generates next-state equations' do
      equations = FsmSynthesizer::EquationGenerator.generate_next_state_equations(fsm)
      expect(equations).to have_key('D0')
      expect(equations['D0']).to be_a(String)
    end

    it 'sets state_bits in FSM' do
      expect(fsm.state_bits).to eq(1)
    end
  end

  describe '.generate_output_equations' do
    context 'Moore machine' do
      let(:fsm) do
        f = FsmSynthesizer::Base.new(
          machine_type: :moore,
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S0' },
            { from: 'S0', input: '1', to: 'S1' },
            { from: 'S1', input: '0', to: 'S1' },
            { from: 'S1', input: '1', to: 'S0' }
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z' }
        )
        FsmSynthesizer::Encoder.encode_binary(f)
        f
      end

      it 'generates output equations for Moore machine' do
        equations = FsmSynthesizer::EquationGenerator.generate_output_equations(fsm)
        expect(equations).to have_key('z')
        expect(equations['z']).to be_a(String)
      end
    end

    context 'Mealy machine' do
      let(:fsm) do
        f = FsmSynthesizer::Base.new(
          machine_type: :mealy,
          inputs: ['0', '1'],
          outputs: ['w'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S0', output: 'w' },
            { from: 'S0', input: '1', to: 'S1', output: 'w' },
            { from: 'S1', input: '0', to: 'S1', output: 'w' },
            { from: 'S1', input: '1', to: 'S0', output: 'w' }
          ]
        )
        FsmSynthesizer::Encoder.encode_binary(f)
        f
      end

      it 'generates output equations for Mealy machine' do
        equations = FsmSynthesizer::EquationGenerator.generate_output_equations(fsm)
        expect(equations).to have_key('w')
        expect(equations['w']).to be_a(String)
      end
    end
  end
end
