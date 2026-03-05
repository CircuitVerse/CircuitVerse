require 'rails_helper'

RSpec.describe FsmSynthesizer::MetastabilityAnalyzer do
  let(:analyzer) { described_class.new }

  let(:fsm) do
    fsm = FsmSynthesizer::Base.new
    fsm.states = ['S0', 'S1', 'S2']
    fsm.inputs = ['X', 'Y', 'external_input']
    fsm.outputs = ['Z']
    fsm.transitions = [
      { from: 'S0', to: 'S1', condition: 'X', output: '0' },
      { from: 'S1', to: 'S2', condition: 'Y', output: '1' },
      { from: 'S2', to: 'S0', condition: 'X & Y', output: '0' }
    ]
    fsm.initial_state = 'S0'
    fsm
  end

  describe '#analyze_crossing' do
    it 'identifies a CDC hazard' do
      hazard = analyzer.analyze_crossing(fsm, 'external_input', 'clk_src', 'clk_sys')

      expect(hazard[:is_hazard]).to be true
      expect(hazard[:input_name]).to eq('external_input')
      expect(hazard[:src_clock]).to eq('clk_src')
      expect(hazard[:dest_clock]).to eq('clk_sys')
    end

    it 'calculates severity value' do
      hazard = analyzer.analyze_crossing(
        fsm, 'external_input', 'clk_src', 'clk_sys',
        100, 100
      )

      expect(hazard[:severity]).to be_a(Float)
      expect(hazard[:severity]).to be_between(0.0, 1.0)
    end

    it 'marks crossing as requiring synchronization' do
      hazard = analyzer.analyze_crossing(fsm, 'external_input', 'clk_src', 'clk_sys')

      expect(hazard[:synchronization_required]).to be true
    end

    it 'provides synchronizer recommendation' do
      hazard = analyzer.analyze_crossing(fsm, 'external_input', 'clk_src', 'clk_sys')

      expect(hazard[:recommended_synchronizer]).to have_key(:type)
      expect(hazard[:recommended_synchronizer]).to have_key(:num_stages)
    end

    it 'analyzes critical factors' do
      hazard = analyzer.analyze_crossing(fsm, 'X', 'clk_src', 'clk_sys')

      expect(hazard[:critical_factors]).to be_an(Array)
    end

    it 'calculates clock frequency ratio' do
      hazard = analyzer.analyze_crossing(
        fsm, 'external_input', 'clk_src', 'clk_sys',
        200, 100
      )

      expect(hazard[:clock_frequency_ratio]).to eq(2.0)
    end

    it 'stores hazard in hazards list' do
      analyzer.analyze_crossing(fsm, 'external_input', 'clk_src', 'clk_sys')

      expect(analyzer.hazards.length).to eq(1)
    end

    it 'raises error for non-existent input' do
      expect do
        analyzer.analyze_crossing(fsm, 'non_existent', 'clk_src', 'clk_sys')
      end.to raise_error(FsmSynthesizer::ValidationError)
    end

    it 'handles different frequency ratios' do
      hazard1 = analyzer.analyze_crossing(
        fsm, 'X', 'clk_src', 'clk_sys',
        100, 100
      )

      analyzer.hazards = []

      hazard2 = analyzer.analyze_crossing(
        fsm, 'X', 'clk_src', 'clk_sys',
        50, 100
      )

      # Different frequency ratios should be correctly computed
      expect(hazard1[:clock_frequency_ratio]).to eq(1.0)
      expect(hazard2[:clock_frequency_ratio]).to eq(0.5)
    end
  end

  describe '#analyze_crossings' do
    it 'analyzes multiple crossings at once' do
      crossings = [
        { input_name: 'X', src_clock: 'clk_src', dest_clock: 'clk_sys' },
        { input_name: 'Y', src_clock: 'clk_src', dest_clock: 'clk_sys' }
      ]

      hazards = analyzer.analyze_crossings(fsm, crossings)

      expect(hazards.length).to eq(2)
    end

    it 'applies custom frequencies to each crossing' do
      crossings = [
        { input_name: 'X', src_clock: 'clk_src', dest_clock: 'clk_sys', 
          freq_src_mhz: 150, freq_dest_mhz: 100 },
        { input_name: 'Y', src_clock: 'clk_src', dest_clock: 'clk_sys',
          freq_src_mhz: 200, freq_dest_mhz: 100 }
      ]

      hazards = analyzer.analyze_crossings(fsm, crossings)

      expect(hazards[0][:clock_frequency_ratio]).to eq(1.5)
      expect(hazards[1][:clock_frequency_ratio]).to eq(2.0)
    end

    it 'clears previous hazards' do
      analyzer.analyze_crossing(fsm, 'X', 'clk_src', 'clk_sys')

      crossings = [
        { input_name: 'Y', src_clock: 'clk_src', dest_clock: 'clk_sys' }
      ]

      analyzer.analyze_crossings(fsm, crossings)

      expect(analyzer.hazards.length).to eq(1)
      expect(analyzer.hazards[0][:input_name]).to eq('Y')
    end
  end

  describe '#assess_synchronizer_safety' do
    let(:synchronizers) do
      {
        'X' => { sync_type: 'two_flop', metastability_msat: 3.5 },
        'Y' => { sync_type: 'two_flop', metastability_msat: 2.5 }
      }
    end

    it 'generates safety assessment' do
      assessment = analyzer.assess_synchronizer_safety(fsm, synchronizers)

      expect(assessment).to have_key(:all_inputs_synchronized)
      expect(assessment).to have_key(:synchronized_inputs)
      expect(assessment).to have_key(:unsynchronized_inputs)
    end

    it 'identifies unsynchronized inputs' do
      assessment = analyzer.assess_synchronizer_safety(fsm, synchronizers)

      expect(assessment[:unsynchronized_inputs]).to include('external_input')
    end

    it 'identifies at-risk inputs (low MSAT)' do
      assessment = analyzer.assess_synchronizer_safety(fsm, synchronizers)

      expect(assessment[:at_risk_inputs]).to include('Y')
    end

    it 'determines overall risk level' do
      assessment = analyzer.assess_synchronizer_safety(fsm, synchronizers)

      expect(assessment[:overall_risk]).to be_a(Symbol)
      expect([:critical, :high, :medium, :low].include?(assessment[:overall_risk])).to be true
    end

    it 'counts safe and risky synchronizers' do
      assessment = analyzer.assess_synchronizer_safety(fsm, synchronizers)

      expect(assessment[:safe_sync_count]).to eq(1)
      expect(assessment[:risky_sync_count]).to eq(1)
    end

    it 'marks as high risk if unsynchronized inputs exist' do
      partial_sync = { 'X' => { sync_type: 'two_flop', metastability_msat: 3.5 } }
      assessment = analyzer.assess_synchronizer_safety(fsm, partial_sync)

      expect(assessment[:overall_risk]).to eq(:high)
    end
  end

  describe '#generate_report' do
    before do
      analyzer.analyze_crossing(fsm, 'X', 'clk_src', 'clk_sys')
      analyzer.analyze_crossing(fsm, 'Y', 'clk_src', 'clk_sys')
    end

    it 'generates comprehensive report' do
      report = analyzer.generate_report(fsm)

      expect(report).to have_key(:timestamp)
      expect(report).to have_key(:fsm_name)
      expect(report).to have_key(:inputs_count)
      expect(report).to have_key(:total_crossings_analyzed)
    end

    it 'includes all analyzed hazards' do
      report = analyzer.generate_report(fsm)

      expect(report[:hazards].length).to eq(2)
    end

    it 'includes synchronizer assessment' do
      synchronizers = { 'X' => { sync_type: 'two_flop', metastability_msat: 3.5 } }
      report = analyzer.generate_report(fsm, synchronizers)

      expect(report[:synchronizer_assessment]).to have_key(:overall_risk)
    end

    it 'includes recommendations' do
      synchronizers = { 'X' => { sync_type: 'two_flop', metastability_msat: 2.5, num_stages: 2 } }
      report = analyzer.generate_report(fsm, synchronizers)

      expect(report[:recommendations]).to be_an(Array)
    end

    it 'includes summary string' do
      report = analyzer.generate_report(fsm)

      expect(report[:summary]).to be_a(String)
      expect(report[:summary]).not_to be_empty
    end
  end

  describe '#get_risk_level' do
    before do
      analyzer.analyze_crossing(fsm, 'X', 'clk_src', 'clk_sys')
    end

    it 'returns risk level for analyzed input' do
      risk = analyzer.get_risk_level('X')

      expect(risk).to be_a(Symbol)
      expect([:critical, :high, :medium, :low].include?(risk)).to be true
    end

    it 'returns :none for unanalyzed input' do
      risk = analyzer.get_risk_level('unknown_input')

      expect(risk).to eq(:none)
    end
  end

  describe '#is_msat_acceptable?' do
    it 'accepts MSAT >= 3.0 by default' do
      expect(analyzer.is_msat_acceptable?(3.0)).to be true
      expect(analyzer.is_msat_acceptable?(3.5)).to be true
      expect(analyzer.is_msat_acceptable?(4.0)).to be true
    end

    it 'rejects MSAT < 3.0 by default' do
      expect(analyzer.is_msat_acceptable?(2.9)).to be false
      expect(analyzer.is_msat_acceptable?(2.0)).to be false
      expect(analyzer.is_msat_acceptable?(1.0)).to be false
    end

    it 'allows custom acceptance threshold' do
      expect(analyzer.is_msat_acceptable?(2.5, 2.0)).to be true
      expect(analyzer.is_msat_acceptable?(1.5, 2.0)).to be false
    end
  end

  describe '#mtbf_category' do
    it 'categorizes very low MSAT' do
      category = analyzer.mtbf_category(0.5)

      expect(category).to include('Unacceptable')
    end

    it 'categorizes low MSAT' do
      category = analyzer.mtbf_category(1.5)

      expect(category).to include('Poor')
    end

    it 'categorizes fair MSAT' do
      category = analyzer.mtbf_category(2.5)

      expect(category).to include('Fair')
    end

    it 'categorizes good MSAT' do
      category = analyzer.mtbf_category(3.5)

      expect(category).to include('Good')
    end

    it 'categorizes excellent MSAT' do
      category = analyzer.mtbf_category(5.0)

      expect(category).to include('Excellent')
    end
  end

  describe 'Critical Factor Analysis' do
    it 'identifies timing-critical inputs' do
      hazard = analyzer.analyze_crossing(fsm, 'X', 'clk_src', 'clk_sys')

      # X is used in 2 out of 3 transitions
      expect(hazard[:critical_factors]).to include(:timing_critical)
    end

    it 'identifies state-dependent inputs' do
      hazard = analyzer.analyze_crossing(fsm, 'X', 'clk_src', 'clk_sys')

      # X affects state transitions
      expect(hazard[:critical_factors]).to include(:state_dependent)
    end

    it 'handles inputs not in critical paths' do
      hazard = analyzer.analyze_crossing(fsm, 'external_input', 'clk_src', 'clk_sys')

      # external_input not used in any transition
      expect(hazard[:critical_factors]).not_to include(:state_dependent)
    end
  end

  describe 'Severity Calculations' do
    it 'lower severity for matched frequencies' do
      hazard = analyzer.analyze_crossing(
        fsm, 'X', 'clk_src', 'clk_sys',
        100, 100
      )

      expect(hazard[:severity]).to be < 0.7
    end

    it 'higher severity for mismatched frequencies' do
      hazard = analyzer.analyze_crossing(
        fsm, 'X', 'clk_src', 'clk_sys',
        250, 100
      )

      expect(hazard[:severity]).to be > 0.8
    end

    it 'increases severity with frequency ratio drift' do
      hazard1 = analyzer.analyze_crossing(
        fsm, 'X', 'clk_src', 'clk_sys',
        120, 100
      )

      analyzer.hazards = []

      hazard2 = analyzer.analyze_crossing(
        fsm, 'Y', 'clk_src', 'clk_sys',
        150, 100
      )

      expect(hazard2[:severity]).to be >= hazard1[:severity]
    end
  end

  describe 'Recommendations Generation' do
    it 'recommends additional stages for low MSAT' do
      synchronizers = { 'X' => { sync_type: 'two_flop', metastability_msat: 2.5, num_stages: 2 } }
      report = analyzer.generate_report(fsm, synchronizers)
      rec = report[:recommendations][0]

      expect(rec[:improvement]).to include('increasing')
    end

    it 'recommends existing configuration for good MSAT' do
      synchronizers = { 'X' => { sync_type: 'two_flop', metastability_msat: 3.5, num_stages: 2 } }
      report = analyzer.generate_report(fsm, synchronizers)
      rec = report[:recommendations][0]

      expect(rec[:improvement]).to include('acceptable')
    end

    it 'suggests stage reduction for over-designed sync' do
      synchronizers = { 'X' => { sync_type: 'two_flop', metastability_msat: 5.0, num_stages: 5 } }
      report = analyzer.generate_report(fsm, synchronizers)
      rec = report[:recommendations][0]

      expect(rec[:improvement]).to include('reduce')
    end
  end

  describe 'Summary Generation' do
    it 'generates summary for no crossings' do
      summary = analyzer.generate_summary

      expect(summary).to include('No clock domain crossings')
    end

    it 'generates summary for critical hazards' do
      analyzer.hazards = [
        { input_name: 'X', risk_level: :critical },
        { input_name: 'Y', risk_level: :critical }
      ]

      summary = analyzer.generate_summary

      expect(summary).to include('CRITICAL')
    end

    it 'generates summary for high-risk hazards' do
      analyzer.hazards = [
        { input_name: 'X', risk_level: :high }
      ]

      summary = analyzer.generate_summary

      expect(summary).to include('WARNING')
    end

    it 'generates summary for safe crossings' do
      analyzer.hazards = [
        { input_name: 'X', risk_level: :low }
      ]

      summary = analyzer.generate_summary

      expect(summary).to include('review')
    end
  end
end
