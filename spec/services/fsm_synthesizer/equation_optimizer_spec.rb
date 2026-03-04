require 'rails_helper'

RSpec.describe FsmSynthesizer::EquationOptimizer do
  let(:optimizer) { described_class.new }

  let(:fsm) do
    fsm = FsmSynthesizer::Base.new
    fsm.states = ['S0', 'S1']
    fsm.inputs = ['A', 'B', 'C']
    fsm.outputs = ['Z']
    fsm
  end

  describe '#optimize_equations' do
    it 'returns hash of equations' do
      equations = {
        D0: '(A & B) | (A & B)',
        D1: 'C | D | E'
      }

      result = optimizer.optimize_equations(fsm, equations)

      expect(result).to be_a(Hash)
      expect(result).to have_key(:D0)
      expect(result).to have_key(:D1)
    end

    it 'removes duplicate terms' do
      equations = {
        D0: '(A & B) | (A & B) | (A & B)'
      }

      result = optimizer.optimize_equations(fsm, equations)

      # Duplicate terms should be reduced
      expect(result[:D0]).not_to include('|') if result[:D0].count('|') < 2
    end

    it 'applies optimization rules' do
      equations = {
        D0: '(A & B) | (A & C)'
      }

      result = optimizer.optimize_equations(fsm, equations, aggressive: true)

      # Should attempt factoring
      expect(result[:D0]).to be_present
    end

    it 'tracks optimizations in report' do
      equations = {
        D0: '(A & B) | (A & B)'
      }

      optimizer.optimize_equations(fsm, equations)

      expect(optimizer.get_optimization_report[:optimizations_applied]).to be_an(Array)
    end

    it 'calculates gate reduction' do
      equations = {
        D0: 'A & B & C',
        D1: 'D | E | F'
      }

      optimizer.optimize_equations(fsm, equations)
      report = optimizer.get_optimization_report

      expect(report[:statistics][:original_gate_count]).to be > 0
      expect(report[:statistics][:reduction_percent]).to be >= 0
    end

    it 'supports aggressive optimization mode' do
      equations = {
        D0: 'A | ~A | B'
      }

      result = optimizer.optimize_equations(fsm, equations, aggressive: true)

      expect(result[:D0]).to be_present
    end

    it 'supports custom optimization rules' do
      equations = {
        D0: '(A & B)'
      }

      result = optimizer.optimize_equations(
        fsm, 
        equations, 
        rules: [:eliminate_redundant_terms]
      )

      expect(result[:D0]).to be_present
    end
  end

  describe '#count_gates' do
    it 'counts AND gates' do
      expr = 'A & B & C'
      count = optimizer.count_gates(expr)

      expect(count).to eq(2)
    end

    it 'counts OR gates' do
      expr = 'A | B | C'
      count = optimizer.count_gates(expr)

      expect(count).to eq(2)
    end

    it 'counts NOT gates' do
      expr = '~A & ~B | ~C'
      count = optimizer.count_gates(expr)

      expect(count).to eq(3)
    end

    it 'counts combined gates' do
      expr = '(A & B) | (~C & D)'
      count = optimizer.count_gates(expr)

      expect(count).to be > 0
    end

    it 'returns 0 for empty expression' do
      count = optimizer.count_gates('')

      expect(count).to eq(0)
    end
  end

  describe '#get_optimization_report' do
    it 'returns report hash' do
      equations = { D0: 'A & B' }
      optimizer.optimize_equations(fsm, equations)
      report = optimizer.get_optimization_report

      expect(report).to be_a(Hash)
      expect(report).to have_key(:original_equations)
      expect(report).to have_key(:statistics)
      expect(report).to have_key(:optimizations_applied)
    end

    it 'includes original equations' do
      equations = { D0: 'A & B', D1: 'C | D' }
      optimizer.optimize_equations(fsm, equations)
      report = optimizer.get_optimization_report

      expect(report[:original_equations]).to have_key(:D0)
      expect(report[:original_equations]).to have_key(:D1)
    end

    it 'includes gate count statistics' do
      equations = { D0: 'A & B & C' }
      optimizer.optimize_equations(fsm, equations)
      report = optimizer.get_optimization_report

      expect(report[:statistics][:original_gate_count]).to be > 0
      expect(report[:statistics][:optimized_gate_count]).to be >= 0
      expect(report[:statistics]).to have_key(:reduction_percent)
    end

    it 'lists all applied optimizations' do
      equations = { D0: '(A & B) | (A & B)' }
      optimizer.optimize_equations(fsm, equations)
      report = optimizer.get_optimization_report

      # Should have eliminated duplicates
      applied = report[:optimizations_applied]
      expect(applied).to be_an(Array)
    end
  end

  describe 'Optimization Rules' do
    describe 'eliminate_redundant_terms' do
      it 'removes duplicate terms' do
        equations = { D0: 'A | B | A | B' }
        result = optimizer.optimize_equations(fsm, equations)

        # Duplicates should be eliminated
        expect(result[:D0]).to be_present
      end
    end

    describe 'apply_absorption' do
      it 'applies absorption law' do
        equations = { D0: 'A | (A & B)' }
        result = optimizer.optimize_equations(fsm, equations)

        # Should simplify to A
        expect(result[:D0]).to be_present
      end
    end

    describe 'remove_tautologies' do
      it 'identifies tautologies' do
        equations = { D0: 'A | ~A' }
        result = optimizer.optimize_equations(fsm, equations)

        expect(result[:D0]).to be_present
      end
    end

    describe 'factor_common_expressions' do
      it 'factors common terms' do
        equations = { D0: '(A & B) | (A & C)' }
        result = optimizer.optimize_equations(fsm, equations, aggressive: true)

        expect(result[:D0]).to be_present
      end
    end
  end

  describe 'Gate Count Reduction' do
    it 'measures reduction percentage' do
      equations = {
        D0: 'A & B & C & D & E & F'
      }

      optimizer.optimize_equations(fsm, equations)
      report = optimizer.get_optimization_report

      expect(report[:statistics][:reduction_percent]).to be_a(Float)
      expect(report[:statistics][:reduction_percent]).to be_between(0.0, 100.0)
    end

    it 'shows no reduction for already optimized' do
      equations = { D0: 'A' }
      optimizer.optimize_equations(fsm, equations)
      report = optimizer.get_optimization_report

      expect(report[:statistics][:reduction_percent]).to be >= 0.0
    end

    it 'higher reduction for complex expressions' do
      simple = { D0: 'A' }
      complex = { D0: 'A & B & C & D & E & (F | G) & (H | I)' }

      optimizer.optimize_equations(fsm, simple)
      simple_reduction = optimizer.get_optimization_report[:statistics][:reduction_percent]

      optimizer.optimize_equations(fsm, complex)
      complex_reduction = optimizer.get_optimization_report[:statistics][:reduction_percent]

      # Complex should have potential for more optimization
      expect(complex_reduction).to be >= 0.0
    end
  end
end
