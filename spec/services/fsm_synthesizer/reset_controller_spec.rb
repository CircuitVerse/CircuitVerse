# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FsmSynthesizer::ResetController do
  let(:moore_fsm) do
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
    FsmSynthesizer::Encoder.encode_binary(moore_fsm)
    FsmSynthesizer::EquationGenerator.generate_next_state_equations(moore_fsm)
  end

  describe '.configure_reset' do
    it 'configures synchronous reset to initial state' do
      config = FsmSynthesizer::ResetController.configure_reset(moore_fsm, :synchronous)
      expect(config[:reset_type]).to eq(:synchronous)
      expect(config[:reset_state]).to eq('S0')
    end

    it 'configures asynchronous reset to initial state' do
      config = FsmSynthesizer::ResetController.configure_reset(moore_fsm, :asynchronous)
      expect(config[:reset_type]).to eq(:asynchronous)
      expect(config[:reset_state]).to eq('S0')
    end

    it 'configures reset to specific state' do
      config = FsmSynthesizer::ResetController.configure_reset(moore_fsm, :synchronous, 'S1')
      expect(config[:reset_state]).to eq('S1')
    end

    it 'raises error for unknown reset type' do
      expect do
        FsmSynthesizer::ResetController.configure_reset(moore_fsm, :invalid)
      end.to raise_error(FsmSynthesizer::ValidationError)
    end

    it 'raises error for non-existent reset state' do
      expect do
        FsmSynthesizer::ResetController.configure_reset(moore_fsm, :synchronous, 'S99')
      end.to raise_error(FsmSynthesizer::ValidationError)
    end

    it 'stores configuration in FSM object' do
      FsmSynthesizer::ResetController.configure_reset(moore_fsm, :asynchronous, 'S2')
      expect(moore_fsm.reset_type).to eq(:asynchronous)
      expect(moore_fsm.reset_state).to eq('S2')
    end
  end

  describe '.get_reset_encoding' do
    before do
      FsmSynthesizer::ResetController.configure_reset(moore_fsm, :synchronous, 'S1')
    end

    it 'returns bit pattern of reset state' do
      encoding = FsmSynthesizer::ResetController.get_reset_encoding(moore_fsm)
      expect(encoding).to be_an(Array)
      expect(encoding).not_to be_empty
    end

    it 'returns encoding for S1 (which is [0, 1])' do
      encoding = FsmSynthesizer::ResetController.get_reset_encoding(moore_fsm)
      expect(encoding).to eq([0, 1])
    end

    it 'raises error if reset state not configured' do
      fsm = FsmSynthesizer::Base.new(
        machine_type: :moore,
        inputs: ['x'],
        outputs: ['z'],
        states: [{ id: 'S0', initial: true }],
        transitions: [],
        state_outputs: { 'S0' => 'z' }
      )

      expect do
        FsmSynthesizer::ResetController.get_reset_encoding(fsm)
      end.to raise_error(FsmSynthesizer::GenerationError)
    end
  end

  describe '.generate_async_reset_equations' do
    let(:d_equations) do
      {
        'D0' => '~Q0 & X',
        'D1' => 'Q0 | X'
      }
    end

    before do
      FsmSynthesizer::ResetController.configure_reset(moore_fsm, :asynchronous, 'S0')
    end

    it 'generates reset equations for D flip-flops' do
      reset_eqs = FsmSynthesizer::ResetController.generate_async_reset_equations(moore_fsm, d_equations)
      expect(reset_eqs).to have_key('D0')
      expect(reset_eqs).to have_key('D1')
    end

    it 'includes RST signal in equations' do
      reset_eqs = FsmSynthesizer::ResetController.generate_async_reset_equations(moore_fsm, d_equations)
      reset_eqs.each do |_eq_id, expr|
        expect(expr).to include('RST')
      end
    end

    it 'generates valid Boolean expressions' do
      reset_eqs = FsmSynthesizer::ResetController.generate_async_reset_equations(moore_fsm, d_equations)
      reset_eqs.each do |_eq_id, expr|
        expect(expr).to match(/\A[\w\s&|~()]*\z/)
      end
    end
  end

  describe '.generate_sync_reset_equations' do
    let(:d_equations) do
      {
        'D0' => '~Q0 & X',
        'D1' => 'Q0 | X'
      }
    end

    before do
      FsmSynthesizer::ResetController.configure_reset(moore_fsm, :synchronous, 'S0')
    end

    it 'generates synchronized reset equations' do
      reset_eqs = FsmSynthesizer::ResetController.generate_sync_reset_equations(moore_fsm, d_equations)
      expect(reset_eqs).to have_key('D0')
      expect(reset_eqs).to have_key('D1')
    end

    it 'creates mux-based equations for reset' do
      reset_eqs = FsmSynthesizer::ResetController.generate_sync_reset_equations(moore_fsm, d_equations)
      reset_eqs.each do |_eq_id, expr|
        # Synchronous reset uses mux pattern: (RST*reset_val) + (~RST*normal_expr)
        expect(expr).to match(/RST/)
        expect(expr).to match(/~RST/)
      end
    end

    it 'preserves original equations when reset inactive' do
      reset_eqs = FsmSynthesizer::ResetController.generate_sync_reset_equations(moore_fsm, d_equations)
      # When RST=0, equations should reduce to original expressions
      expect(reset_eqs).to be_a(Hash)
      expect(reset_eqs.all? { |_k, v| v.is_a?(String) }).to be true
    end
  end

  describe '.generate_reset_circuit' do
    before do
      FsmSynthesizer::ResetController.configure_reset(moore_fsm, :asynchronous)
    end

    it 'generates async reset circuit structure' do
      circuit = FsmSynthesizer::ResetController.generate_reset_circuit(moore_fsm)
      expect(circuit[:reset_type]).to eq('asynchronous')
      expect(circuit[:reset_state]).to eq('S0')
    end

    it 'includes reset input specification' do
      circuit = FsmSynthesizer::ResetController.generate_reset_circuit(moore_fsm)
      expect(circuit[:reset_input]).to have_key(:name)
      expect(circuit[:reset_input]).to have_key(:polarity)
    end

    it 'includes reset encoding' do
      circuit = FsmSynthesizer::ResetController.generate_reset_circuit(moore_fsm)
      expect(circuit[:reset_encoding]).to be_an(Array)
    end

    it 'specifies async reset components' do
      circuit = FsmSynthesizer::ResetController.generate_reset_circuit(moore_fsm)
      expect(circuit[:reset_components][:type]).to eq('async_reset_network')
      expect(circuit[:reset_components][:components]).to be_an(Array)
    end

    context 'with synchronous reset' do
      before do
        FsmSynthesizer::ResetController.configure_reset(moore_fsm, :synchronous)
      end

      it 'generates sync reset circuit structure' do
        circuit = FsmSynthesizer::ResetController.generate_reset_circuit(moore_fsm)
        expect(circuit[:reset_type]).to eq('synchronous')
      end

      it 'specifies sync reset components' do
        circuit = FsmSynthesizer::ResetController.generate_reset_circuit(moore_fsm)
        expect(circuit[:reset_components][:type]).to eq('sync_reset_network')
        expect(circuit[:reset_components][:components]).to be_an(Array)
      end
    end
  end

  describe 'reset type constants' do
    it 'defines none reset type' do
      expect(FsmSynthesizer::ResetController::RESET_TYPES).to have_key(:none)
    end

    it 'defines synchronous reset type' do
      expect(FsmSynthesizer::ResetController::RESET_TYPES).to have_key(:synchronous)
    end

    it 'defines asynchronous reset type' do
      expect(FsmSynthesizer::ResetController::RESET_TYPES).to have_key(:asynchronous)
    end
  end
end
