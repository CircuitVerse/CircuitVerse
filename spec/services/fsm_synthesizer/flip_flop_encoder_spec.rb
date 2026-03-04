# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FsmSynthesizer::FlipFlopEncoder do
  let(:moore_fsm) do
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

  before do
    FsmSynthesizer::Encoder.encode_binary(moore_fsm)
    FsmSynthesizer::EquationGenerator.generate_next_state_equations(moore_fsm)
  end

  describe '.generate_excitation_equations' do
    context 'with D flip-flop' do
      it 'generates D flip-flop excitation equations' do
        equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :d)

        expect(equations).to be_a(Hash)
        expect(equations).to have_key('D0')
      end

      it 'D equations match next-state equations' do
        equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :d)

        moore_fsm.state_bits.times do |i|
          expect(equations["D#{i}"]).to eq(moore_fsm.next_state_equations["D#{i}"])
        end
      end

      it 'produces valid Boolean expressions' do
        equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :d)

        equations.each do |_eq_id, expr|
          expect(expr).to match(/\A[\d\w\s&|~()]*\z/)
        end
      end
    end

    context 'with JK flip-flop' do
      it 'generates J and K equations' do
        equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :jk)

        expect(equations).to have_key('J0')
        expect(equations).to have_key('K0')
      end

      it 'returns 2N equations (J and K for each bit)' do
        equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :jk)

        expect(equations.size).to eq(moore_fsm.state_bits * 2)
      end

      it 'includes both J and K for all state bits' do
        equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :jk)

        moore_fsm.state_bits.times do |i|
          expect(equations).to have_key("J#{i}")
          expect(equations).to have_key("K#{i}")
        end
      end
    end

    context 'with SR flip-flop' do
      it 'generates S and R equations' do
        equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :sr)

        expect(equations).to have_key('S0')
        expect(equations).to have_key('R0')
      end

      it 'returns 2N equations (S and R for each bit)' do
        equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :sr)

        expect(equations.size).to eq(moore_fsm.state_bits * 2)
      end

      it 'includes both S and R for all state bits' do
        equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :sr)

        moore_fsm.state_bits.times do |i|
          expect(equations).to have_key("S#{i}")
          expect(equations).to have_key("R#{i}")
        end
      end
    end

    context 'with unsupported flip-flop type' do
      it 'raises ValidationError' do
        expect do
          FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :invalid)
        end.to raise_error(FsmSynthesizer::ValidationError)
      end
    end
  end

  describe 'flip-flop type constants' do
    it 'defines D flip-flop' do
      expect(FsmSynthesizer::FlipFlopEncoder::FF_TYPES).to have_key(:d)
    end

    it 'defines JK flip-flop' do
      expect(FsmSynthesizer::FlipFlopEncoder::FF_TYPES).to have_key(:jk)
    end

    it 'defines SR flip-flop' do
      expect(FsmSynthesizer::FlipFlopEncoder::FF_TYPES).to have_key(:sr)
    end
  end

  describe 'integration with synthesis pipeline' do
    it 'works with complete Moore FSM synthesis' do
      equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(moore_fsm, :jk)

      moore_fsm.state_bits.times do |i|
        expect(equations["J#{i}"]).to be_present
        expect(equations["K#{i}"]).to be_present
      end
    end

    context 'with 3-state FSM' do
      let(:three_state_fsm) do
        FsmSynthesizer::Base.new(
          machine_type: :moore,
          inputs: ['0', '1'],
          outputs: ['y'],
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
          state_outputs: { 'S0' => 'y', 'S1' => 'y', 'S2' => 'y' }
        )
      end

      before do
        FsmSynthesizer::Encoder.encode_binary(three_state_fsm)
        FsmSynthesizer::EquationGenerator.generate_next_state_equations(three_state_fsm)
      end

      it 'generates correct number of equations for all flip-flop types' do
        d_eqs = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(three_state_fsm, :d)
        jk_eqs = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(three_state_fsm, :jk)
        sr_eqs = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(three_state_fsm, :sr)

        expect(d_eqs.size).to eq(2) # 2 bits for 3 states
        expect(jk_eqs.size).to eq(4) # J0, K0, J1, K1
        expect(sr_eqs.size).to eq(4) # S0, R0, S1, R1
      end
    end
  end
end
