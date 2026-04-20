require 'rails_helper'

RSpec.describe FsmSynthesizer::Base do
  describe 'initialization and data model' do
    let(:moore_fsm) do
      FsmSynthesizer::Base.new(
        machine_type: :moore,
        inputs: ['0', '1'],
        outputs: ['z'],
        states: [{ id: 'S0', initial: true }, { id: 'S1' }],
        transitions: [{ from: 'S0', input: '0', to: 'S0' }],
        state_outputs: { 'S0' => 'z' }
      )
    end

    it 'creates a Moore FSM instance' do
      expect(moore_fsm.machine_type).to eq(:moore)
      expect(moore_fsm.states.size).to eq(2)
    end

    it 'stores inputs and outputs' do
      expect(moore_fsm.inputs).to eq(['0', '1'])
      expect(moore_fsm.outputs).to eq(['z'])
    end
  end

  describe 'validation' do
    context 'valid Moore FSM' do
      let(:valid_moore) do
        FsmSynthesizer::Base.new(
          machine_type: :moore,
          inputs: ['0'],
          outputs: ['y'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S1' },
            { from: 'S1', input: '0', to: 'S0' }
          ],
          state_outputs: { 'S0' => 'y', 'S1' => 'y' }
        )
      end

      it 'passes validation' do
        expect { valid_moore.validate }.not_to raise_error
      end
    end

    context 'invalid machine type' do
      let(:invalid_type) do
        FsmSynthesizer::Base.new(
          machine_type: :invalid,
          inputs: ['0'],
          outputs: ['y'],
          states: [{ id: 'S0', initial: true }],
          transitions: [],
          state_outputs: {}
        )
      end

      it 'raises ValidationError' do
        expect { invalid_type.validate }.to raise_error(FsmSynthesizer::ValidationError)
      end
    end

    context 'missing initial state' do
      let(:no_initial) do
        FsmSynthesizer::Base.new(
          machine_type: :moore,
          inputs: ['0'],
          outputs: ['y'],
          states: [{ id: 'S0' }, { id: 'S1' }],
          transitions: [],
          state_outputs: {}
        )
      end

      it 'raises ValidationError' do
        expect { no_initial.validate }.to raise_error(FsmSynthesizer::ValidationError)
      end
    end

    context 'unknown state in transition' do
      let(:unknown_state) do
        FsmSynthesizer::Base.new(
          machine_type: :moore,
          inputs: ['0'],
          outputs: ['y'],
          states: [{ id: 'S0', initial: true }],
          transitions: [{ from: 'S0', input: '0', to: 'S_UNKNOWN' }],
          state_outputs: { 'S0' => 'y' }
        )
      end

      it 'raises ValidationError' do
        expect { unknown_state.validate }.to raise_error(FsmSynthesizer::ValidationError)
      end
    end
  end
end
