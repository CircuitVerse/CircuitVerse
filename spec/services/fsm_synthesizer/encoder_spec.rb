require 'rails_helper'

RSpec.describe FsmSynthesizer::Encoder do
  let(:fsm) do
    FsmSynthesizer::Base.new(
      machine_type: :moore,
      inputs: ['0', '1'],
      outputs: ['z'],
      states: [
        { id: 'S0', initial: true },
        { id: 'S1' },
        { id: 'S2' }
      ],
      transitions: [
        { from: 'S0', input: '0', to: 'S0' },
        { from: 'S0', input: '1', to: 'S1' },
        { from: 'S1', input: '0', to: 'S2' },
        { from: 'S1', input: '1', to: 'S0' },
        { from: 'S2', input: '0', to: 'S1' },
        { from: 'S2', input: '1', to: 'S0' }
      ],
      state_outputs: { 'S0' => 'z', 'S1' => 'z', 'S2' => 'z' }
    )
  end

  describe '.encode_binary' do
    it 'assigns binary encodings to states' do
      encoding = FsmSynthesizer::Encoder.encode_binary(fsm)
      expect(encoding['S0']).to eq([0, 0])
      expect(encoding['S1']).to eq([0, 1])
      expect(encoding['S2']).to eq([1, 0])
    end

    it 'sets state_bits correctly' do
      FsmSynthesizer::Encoder.encode_binary(fsm)
      expect(fsm.state_bits).to eq(2)
    end
  end

  describe '.encode_one_hot' do
    it 'assigns one-hot encodings to states' do
      encoding = FsmSynthesizer::Encoder.encode_one_hot(fsm)
      expect(encoding['S0']).to eq([1, 0, 0])
      expect(encoding['S1']).to eq([0, 1, 0])
      expect(encoding['S2']).to eq([0, 0, 1])
    end

    it 'sets state_bits to number of states' do
      FsmSynthesizer::Encoder.encode_one_hot(fsm)
      expect(fsm.state_bits).to eq(3)
    end
  end
end
