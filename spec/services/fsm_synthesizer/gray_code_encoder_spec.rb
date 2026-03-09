# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FsmSynthesizer::GrayCodeEncoder do
  describe '.to_gray_code' do
    it 'converts 0 to all zeros' do
      result = FsmSynthesizer::GrayCodeEncoder.to_gray_code(0, 3)
      expect(result).to eq([0, 0, 0])
    end

    it 'converts 1 to 001' do
      result = FsmSynthesizer::GrayCodeEncoder.to_gray_code(1, 3)
      expect(result).to eq([0, 0, 1])
    end

    it 'converts 2 to 011 (Gray code differs from binary 010)' do
      result = FsmSynthesizer::GrayCodeEncoder.to_gray_code(2, 3)
      expect(result).to eq([0, 1, 1])
    end

    it 'converts 3 to 010' do
      result = FsmSynthesizer::GrayCodeEncoder.to_gray_code(3, 3)
      expect(result).to eq([0, 1, 0])
    end

    it 'converts 5 to 111' do
      result = FsmSynthesizer::GrayCodeEncoder.to_gray_code(5, 3)
      expect(result).to eq([1, 1, 1])
    end

    it 'converts 7 to 100' do
      result = FsmSynthesizer::GrayCodeEncoder.to_gray_code(7, 3)
      expect(result).to eq([1, 0, 0])
    end

    it 'returns correct bit width' do
      result = FsmSynthesizer::GrayCodeEncoder.to_gray_code(3, 4)
      expect(result.size).to eq(4)
    end

    it 'raises error for negative number' do
      expect do
        FsmSynthesizer::GrayCodeEncoder.to_gray_code(-1, 3)
      end.to raise_error(FsmSynthesizer::EncodingError)
    end

    it 'raises error for number too large' do
      expect do
        FsmSynthesizer::GrayCodeEncoder.to_gray_code(8, 3)  # 8 needs 4 bits
      end.to raise_error(FsmSynthesizer::EncodingError)
    end

    it 'raises error for invalid bit width' do
      expect do
        FsmSynthesizer::GrayCodeEncoder.to_gray_code(1, 0)
      end.to raise_error(FsmSynthesizer::EncodingError)
    end
  end

  describe '.differ_by_one_bit?' do
    it 'returns true for Gray codes differing by 1 bit' do
      bits1 = [0, 0, 0]  # Gray: 0
      bits2 = [0, 0, 1]  # Gray: 1
      expect(FsmSynthesizer::GrayCodeEncoder.differ_by_one_bit?(bits1, bits2)).to be true
    end

    it 'returns true for 2 to 3 transition' do
      bits1 = [0, 1, 1]  # Gray: 2
      bits2 = [0, 1, 0]  # Gray: 3
      expect(FsmSynthesizer::GrayCodeEncoder.differ_by_one_bit?(bits1, bits2)).to be true
    end

    it 'returns false for arrays differing by 2 bits' do
      bits1 = [0, 0, 0]
      bits2 = [0, 1, 1]
      expect(FsmSynthesizer::GrayCodeEncoder.differ_by_one_bit?(bits1, bits2)).to be false
    end

    it 'returns false for identical arrays' do
      bits1 = [0, 0, 1]
      bits2 = [0, 0, 1]
      expect(FsmSynthesizer::GrayCodeEncoder.differ_by_one_bit?(bits1, bits2)).to be false
    end

    it 'returns false for different sized arrays' do
      bits1 = [0, 0, 1]
      bits2 = [0, 0, 1, 0]
      expect(FsmSynthesizer::GrayCodeEncoder.differ_by_one_bit?(bits1, bits2)).to be false
    end
  end

  describe '.encode' do
    let(:moore_fsm) do
      FsmSynthesizer::Base.new(
        machine_type: :moore,
        inputs: ['0', '1'],
        outputs: ['z'],
        states: [
          { id: 'S0', initial: true },
          { id: 'S1' },
          { id: 'S2' },
          { id: 'S3' }
        ],
        transitions: [
          { from: 'S0', input: '0', to: 'S0' },
          { from: 'S0', input: '1', to: 'S1' },
          { from: 'S1', input: '0', to: 'S2' },
          { from: 'S1', input: '1', to: 'S3' },
          { from: 'S2', input: '0', to: 'S0' },
          { from: 'S2', input: '1', to: 'S3' },
          { from: 'S3', input: '0', to: 'S2' },
          { from: 'S3', input: '1', to: 'S0' }
        ],
        state_outputs: { 'S0' => 'z', 'S1' => 'z', 'S2' => 'z', 'S3' => 'z' }
      )
    end

    before do
      FsmSynthesizer::Encoder.encode_binary(moore_fsm)
    end

    it 'encodes all states' do
      FsmSynthesizer::GrayCodeEncoder.encode(moore_fsm)
      expect(moore_fsm.state_encoding).to have_key('S0')
      expect(moore_fsm.state_encoding).to have_key('S3')
    end

    it 'assigns different encodings to different states' do
      FsmSynthesizer::GrayCodeEncoder.encode(moore_fsm)
      encodings = moore_fsm.state_encoding.values
      expect(encodings.uniq.size).to eq(4)
    end

    it 'uses correct number of bits' do
      FsmSynthesizer::GrayCodeEncoder.encode(moore_fsm)
      moore_fsm.state_encoding.each do |_state, bits|
        expect(bits.size).to eq(moore_fsm.state_bits)
      end
    end

    it 'encodes S0 as all zeros' do
      FsmSynthesizer::GrayCodeEncoder.encode(moore_fsm)
      expect(moore_fsm.state_encoding['S0']).to eq([0, 0])
    end

    it 'encodes S1 following Gray code' do
      FsmSynthesizer::GrayCodeEncoder.encode(moore_fsm)
      expect(moore_fsm.state_encoding['S1']).to eq([0, 1])
    end

    it 'encodes S2 following Gray code' do
      FsmSynthesizer::GrayCodeEncoder.encode(moore_fsm)
      expect(moore_fsm.state_encoding['S2']).to eq([1, 1])
    end

    it 'encodes S3 following Gray code' do
      FsmSynthesizer::GrayCodeEncoder.encode(moore_fsm)
      expect(moore_fsm.state_encoding['S3']).to eq([1, 0])
    end

    it 'raises error if state_bits not set' do
      fsm = FsmSynthesizer::Base.new(
        machine_type: :moore,
        inputs: ['0', '1'],
        outputs: ['z'],
        states: [{ id: 'S0', initial: true }],
        transitions: [],
        state_outputs: { 'S0' => 'z' }
      )

      expect do
        FsmSynthesizer::GrayCodeEncoder.encode(fsm)
      end.to raise_error(FsmSynthesizer::EncodingError)
    end
  end

  describe '.count_multibit_changes' do
    let(:fsm) do
      FsmSynthesizer::Base.new(
        machine_type: :moore,
        inputs: ['x'],
        outputs: ['z'],
        states: [
          { id: 'S0', initial: true },
          { id: 'S1' },
          { id: 'S2' }
        ],
        transitions: [
          { from: 'S0', input: 'x', to: 'S1' },
          { from: 'S1', input: 'x', to: 'S2' },
          { from: 'S2', input: 'x', to: 'S0' }
        ],
        state_outputs: { 'S0' => 'z', 'S1' => 'z', 'S2' => 'z' }
      )
    end

    it 'counts multi-bit transitions in Gray code' do
      FsmSynthesizer::Encoder.encode_binary(fsm)
      FsmSynthesizer::GrayCodeEncoder.encode(fsm)
      count = FsmSynthesizer::GrayCodeEncoder.count_multibitechanges(fsm)
      expect(count).to be_a(Integer)
      expect(count).to be >= 0
    end

    it 'returns 0 for all adjacent Gray codes' do
      FsmSynthesizer::Encoder.encode_binary(fsm)
      FsmSynthesizer::GrayCodeEncoder.encode(fsm)
      # S0->S1: [0,0]->[0,1] (1 bit), S1->S2: [0,1]->[1,1] (1 bit), S2->S0: [1,1]->[1,0] (1 bit)
      count = FsmSynthesizer::GrayCodeEncoder.count_multibitechanges(fsm)
      expect(count).to eq(0)  # All Gray code transitions are single-bit
    end
  end

  describe '.compare_encodings' do
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

    before do
      FsmSynthesizer::Encoder.encode_binary(fsm)
      FsmSynthesizer::GrayCodeEncoder.encode(fsm)
    end

    it 'returns comparison hash with all metrics' do
      comparison = FsmSynthesizer::GrayCodeEncoder.compare_encodings(fsm)
      expect(comparison).to have_key(:gray_code)
      expect(comparison).to have_key(:binary)
      expect(comparison).to have_key(:one_hot)
      expect(comparison).to have_key(:best_encoding)
      expect(comparison).to have_key(:recommendation)
    end

    it 'includes numeric multi-bit counts' do
      comparison = FsmSynthesizer::GrayCodeEncoder.compare_encodings(fsm)
      expect(comparison[:gray_code]).to be_a(Integer)
      expect(comparison[:binary]).to be_a(Integer)
      expect(comparison[:one_hot]).to be_a(Integer)
    end

    it 'identifies best encoding' do
      comparison = FsmSynthesizer::GrayCodeEncoder.compare_encodings(fsm)
      expect(['gray_code', 'binary', 'one_hot']).to include(comparison[:best_encoding])
    end
  end

  describe 'Gray code properties' do
    it 'guarantees single-bit differences between consecutive values' do
      (0...8).each do |i|
        bits1 = FsmSynthesizer::GrayCodeEncoder.to_gray_code(i, 3)
        bits2 = FsmSynthesizer::GrayCodeEncoder.to_gray_code((i + 1) % 8, 3)
        # Note: Wrapping (7->0) is allowed to differ by 1 in cyclic Gray code
        expect(FsmSynthesizer::GrayCodeEncoder.differ_by_one_bit?(bits1, bits2)).to be true
      end
    end
  end
end
