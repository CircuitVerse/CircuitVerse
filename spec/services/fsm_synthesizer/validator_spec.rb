require 'rails_helper'

RSpec.describe FsmSynthesizer::Validator do
  describe '.check_determinism' do
    context 'deterministic FSM' do
      let(:fsm) do
        FsmSynthesizer::Base.new(
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
      end

      it 'passes determinism check' do
        expect { FsmSynthesizer::Validator.check_determinism(fsm) }.not_to raise_error
      end
    end

    context 'non-deterministic FSM (duplicate transition)' do
      let(:fsm) do
        FsmSynthesizer::Base.new(
          machine_type: :moore,
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S0' },
            { from: 'S0', input: '0', to: 'S1' } # Duplicate!
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z' }
        )
      end

      it 'raises ValidationError' do
        expect { FsmSynthesizer::Validator.check_determinism(fsm) }.to raise_error(FsmSynthesizer::ValidationError)
      end
    end
  end

  describe '.check_completeness' do
    context 'complete FSM' do
      let(:fsm) do
        FsmSynthesizer::Base.new(
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
      end

      it 'passes completeness check' do
        expect { FsmSynthesizer::Validator.check_completeness(fsm) }.not_to raise_error
      end
    end

    context 'incomplete FSM (missing transition)' do
      let(:fsm) do
        FsmSynthesizer::Base.new(
          machine_type: :moore,
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S0' }
            # Missing S0->1, S1->0, S1->1
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z' }
        )
      end

      it 'raises ValidationError' do
        expect { FsmSynthesizer::Validator.check_completeness(fsm) }.to raise_error(FsmSynthesizer::ValidationError)
      end
    end
  end
end
