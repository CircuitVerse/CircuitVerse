require 'rails_helper'

RSpec.describe FsmSynthesizer::Parser do
  describe '.parse_json' do
    context 'valid Moore FSM JSON' do
      let(:moore_json) do
        {
          machine_type: 'moore',
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
        }.to_json
      end

      it 'parses and returns valid FSM object' do
        fsm = FsmSynthesizer::Parser.parse_json(moore_json)
        expect(fsm).to be_a(FsmSynthesizer::Base)
        expect(fsm.machine_type).to eq(:moore)
        expect(fsm.states.size).to eq(2)
      end

      it 'validates and does not raise' do
        expect { FsmSynthesizer::Parser.parse_json(moore_json) }.not_to raise_error
      end
    end

    context 'valid Mealy FSM JSON' do
      let(:mealy_json) do
        {
          machine_type: 'mealy',
          inputs: ['0', '1'],
          outputs: ['w'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S0', output: 'w' },
            { from: 'S0', input: '1', to: 'S1', output: 'w' },
            { from: 'S1', input: '0', to: 'S1', output: 'w' },
            { from: 'S1', input: '1', to: 'S0', output: 'w' }
          ]
        }.to_json
      end

      it 'parses Mealy FSM' do
        fsm = FsmSynthesizer::Parser.parse_json(mealy_json)
        expect(fsm.machine_type).to eq(:mealy)
      end
    end

    context 'invalid JSON' do
      it 'raises ValidationError on malformed JSON' do
        expect { FsmSynthesizer::Parser.parse_json('{ invalid json }') }
          .to raise_error(FsmSynthesizer::ValidationError)
      end
    end

    context 'missing required fields' do
      it 'raises ValidationError' do
        incomplete = { machine_type: 'moore', inputs: ['0'] }.to_json
        expect { FsmSynthesizer::Parser.parse_json(incomplete) }
          .to raise_error(FsmSynthesizer::ValidationError)
      end
    end
  end

  describe '.parse_csv' do
    context 'valid Moore FSM CSV' do
      let(:moore_csv) do
        <<~CSV
          machine_type: moore
          inputs: 0,1
          outputs: z
          states: S0(initial),S1
          state_outputs:
          S0,z
          S1,z
          transitions:
          from,input,to,output
          S0,0,S0,
          S0,1,S1,
          S1,0,S1,
          S1,1,S0,
        CSV
      end

      it 'parses Moore FSM from CSV' do
        fsm = FsmSynthesizer::Parser.parse_csv(moore_csv)
        expect(fsm).to be_a(FsmSynthesizer::Base)
        expect(fsm.machine_type).to eq(:moore)
        expect(fsm.states.size).to eq(2)
      end

      it 'preserves initial state marker' do
        fsm = FsmSynthesizer::Parser.parse_csv(moore_csv)
        initial = fsm.states.find { |s| s[:initial] }
        expect(initial&.dig(:id)).to eq('S0')
      end
    end

    context 'valid Mealy FSM CSV' do
      let(:mealy_csv) do
        <<~CSV
          machine_type: mealy
          inputs: 0,1
          outputs: w
          states: S0(initial),S1
          transitions:
          from,input,to,output
          S0,0,S0,w
          S0,1,S1,w
          S1,0,S1,w
          S1,1,S0,w
        CSV
      end

      it 'parses Mealy FSM from CSV' do
        fsm = FsmSynthesizer::Parser.parse_csv(mealy_csv)
        expect(fsm.machine_type).to eq(:mealy)
        expect(fsm.transitions.size).to eq(4)
      end
    end

    context 'CSV with comments' do
      let(:csv_with_comments) do
        <<~CSV
          # This is a comment
          machine_type: moore
          # Another comment
          inputs: 0,1
          outputs: z
          states: S0(initial),S1
          state_outputs:
          S0,z
          S1,z
          transitions:
          from,input,to,output
          S0,0,S0,
          S0,1,S1,
          S1,0,S1,
          S1,1,S0,
        CSV
      end

      it 'ignores comment lines' do
        fsm = FsmSynthesizer::Parser.parse_csv(csv_with_comments)
        expect(fsm).to be_a(FsmSynthesizer::Base)
      end
    end

    context 'CSV with empty lines' do
      let(:csv_with_blanks) do
        <<~CSV
          machine_type: moore
          inputs: 0,1

          outputs: z
          states: S0(initial),S1

          state_outputs:
          S0,z
          S1,z
          transitions:
          from,input,to,output
          S0,0,S0,
          S0,1,S1,
          S1,0,S1,
          S1,1,S0,
        CSV
      end

      it 'handles empty lines gracefully' do
        fsm = FsmSynthesizer::Parser.parse_csv(csv_with_blanks)
        expect(fsm).to be_a(FsmSynthesizer::Base)
      end
    end
  end

  describe '.parse_hash' do
    context 'with string keys' do
      let(:hash_with_string_keys) do
        {
          'machine_type' => 'moore',
          'inputs' => ['0', '1'],
          'outputs' => ['z'],
          'states' => [{ 'id' => 'S0', 'initial' => true }, { 'id' => 'S1' }],
          'transitions' => [
            { 'from' => 'S0', 'input' => '0', 'to' => 'S0' },
            { 'from' => 'S0', 'input' => '1', 'to' => 'S1' },
            { 'from' => 'S1', 'input' => '0', 'to' => 'S1' },
            { 'from' => 'S1', 'input' => '1', 'to' => 'S0' }
          ],
          'state_outputs' => { 'S0' => 'z', 'S1' => 'z' }
        }
      end

      it 'parses hash with string keys' do
        fsm = FsmSynthesizer::Parser.parse_hash(hash_with_string_keys)
        expect(fsm).to be_a(FsmSynthesizer::Base)
        expect(fsm.machine_type).to eq(:moore)
      end
    end

    context 'with symbol keys' do
      let(:hash_with_symbol_keys) do
        {
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
        }
      end

      it 'parses hash with symbol keys' do
        fsm = FsmSynthesizer::Parser.parse_hash(hash_with_symbol_keys)
        expect(fsm).to be_a(FsmSynthesizer::Base)
      end
    end
  end

  describe 'integration with Phase 1' do
    let(:valid_fsm_json) do
      {
        machine_type: 'moore',
        inputs: ['0', '1'],
        outputs: ['y'],
        states: [{ id: 'S0', initial: true }, { id: 'S1' }, { id: 'S2' }],
        transitions: [
          { from: 'S0', input: '0', to: 'S0' },
          { from: 'S0', input: '1', to: 'S1' },
          { from: 'S1', input: '0', to: 'S2' },
          { from: 'S1', input: '1', to: 'S0' },
          { from: 'S2', input: '0', to: 'S1' },
          { from: 'S2', input: '1', to: 'S0' }
        ],
        state_outputs: { 'S0' => 'y', 'S1' => 'y', 'S2' => 'y' }
      }.to_json
    end

    it 'produces FSM ready for encoding' do
      fsm = FsmSynthesizer::Parser.parse_json(valid_fsm_json)
      FsmSynthesizer::Encoder.encode_binary(fsm)
      expect(fsm.state_encoding).not_to be_empty
    end

    it 'produces FSM ready for equation generation' do
      fsm = FsmSynthesizer::Parser.parse_json(valid_fsm_json)
      FsmSynthesizer::Encoder.encode_binary(fsm)
      FsmSynthesizer::EquationGenerator.generate_next_state_equations(fsm)
      expect(fsm.next_state_equations).not_to be_empty
    end

    it 'produces FSM ready for circuit mapping' do
      fsm = FsmSynthesizer::Parser.parse_json(valid_fsm_json)
      FsmSynthesizer::Encoder.encode_binary(fsm)
      FsmSynthesizer::EquationGenerator.generate_next_state_equations(fsm)
      FsmSynthesizer::EquationGenerator.generate_output_equations(fsm)
      circuit = FsmSynthesizer::CircuitMapper.generate_circuit(fsm)
      expect(circuit).to have_key(:components)
    end
  end
end
