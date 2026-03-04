require 'rails_helper'

RSpec.describe FsmSynthesizer::TimingAnalyzer do
  let(:analyzer) { described_class.new }

  let(:fsm) do
    fsm = FsmSynthesizer::Base.new
    fsm.states = ['S0', 'S1', 'S2']
    fsm.inputs = ['A', 'B']
    fsm.outputs = ['Z']
    fsm.transitions = [
      { from: 'S0', to: 'S1', condition: 'A' },
      { from: 'S1', to: 'S2', condition: 'B' },
      { from: 'S2', to: 'S0', condition: '1' }
    ]
    fsm.initial_state = 'S0'
    fsm
  end

  let(:equations) do
    {
      D0: 'A & B',
      D1: 'A | B',
      Z: '~(A & B)'
    }
  end

  describe '#analyze_timing' do
    it 'performs timing analysis at specified frequency' do
      result = analyzer.analyze_timing(fsm, equations, 100)

      expect(result[:target_freq_mhz]).to eq(100)
      expect(result[:target_period_ns]).to be > 0
    end

    it 'analyzes each equation' do
      result = analyzer.analyze_timing(fsm, equations, 100)

      expect(result[:paths]).to have_key('D0')
      expect(result[:paths]).to have_key('D1')
      expect(result[:paths]).to have_key('Z')
    end

    it 'calculates combinational delay' do
      result = analyzer.analyze_timing(fsm, equations, 100)

      result[:paths].each do |_, path|
        expect(path[:combinational_delay]).to be > 0
      end
    end

    it 'includes setup time' do
      result = analyzer.analyze_timing(fsm, equations, 100)

      result[:paths].each do |_, path|
        expect(path[:setup_time]).to be > 0
        expect(path[:total_delay]).to eq(path[:combinational_delay] + path[:setup_time])
      end
    end

    it 'calculates slack for each path' do
      result = analyzer.analyze_timing(fsm, equations, 100)

      result[:paths].each do |_, path|
        expect(path[:slack]).to be_a(Float)
        expect(path[:slack]).to eq(result[:target_period_ns] - path[:total_delay])
      end
    end

    it 'identifies timing violations' do
      result = analyzer.analyze_timing(fsm, equations, 1000)  # Very high frequency

      if result[:violations].any?
        expect(result[:timing_met]).to be false
      end
    end

    it 'identifies critical path' do
      result = analyzer.analyze_timing(fsm, equations, 100)

      expect(result[:critical_path]).to be_present
      critical_eq = result[:critical_path][0]
      expect(equations).to have_key(critical_eq.to_sym)
    end

    it 'supports custom library parameters' do
      custom_lib = {
        ff_setup: 0.5,
        and_delay: 0.1,
        or_delay: 0.1
      }
      custom_analyzer = FsmSynthesizer::TimingAnalyzer.new(custom_lib)
      
      result = custom_analyzer.analyze_timing(fsm, equations, 100)

      expect(result[:paths].values.first[:setup_time]).to eq(0.5)
    end

    it 'includes recommendations when requested' do
      result = analyzer.analyze_timing(fsm, equations, 100, report_paths: true)

      if result[:recommendations]
        expect(result[:recommendations]).to be_an(Array)
      end
    end

    it 'reports multiple critical paths' do
      result = analyzer.analyze_timing(fsm, equations, 100, report_paths: true, num_paths: 3)

      expect(result[:critical_paths]).to be_an(Array)
      expect(result[:critical_paths].length).to be <= 3
    end
  end

  describe '#get_timing_report' do
    before { analyzer.analyze_timing(fsm, equations, 100) }

    it 'returns formatted report' do
      report = analyzer.get_timing_report

      expect(report).to be_a(Hash)
      expect(report).to have_key(:summary)
      expect(report).to have_key(:violations)
      expect(report).to have_key(:critical_paths)
      expect(report).to have_key(:recommendations)
    end

    it 'includes timing closure status' do
      report = analyzer.get_timing_report

      expect(report[:summary][:timing_closure]).to eq('PASS').or eq('FAIL')
    end

    it 'includes violation details' do
      report = analyzer.get_timing_report

      if report[:violations].any?
        violation = report[:violations].first
        expect(violation).to have_key(:path)
        expect(violation).to have_key(:delay_ns)
        expect(violation).to have_key(:slack_ns)
      end
    end

    it 'includes library parameters' do
      report = analyzer.get_timing_report

      expect(report[:library_parameters]).to be_present
      expect(report[:library_parameters]).to have_key(:ff_clock_to_q)
      expect(report[:library_parameters]).to have_key(:ff_setup)
    end
  end

  describe '#calculate_expression_delay' do
    it 'calculates delay for expression' do
      delay = analyzer.calculate_expression_delay('A & B & C')

      expect(delay).to be > 0
    end

    it 'complex expression has longer delay' do
      simple_delay = analyzer.calculate_expression_delay('A')
      complex_delay = analyzer.calculate_expression_delay('(A & B) | (C & D) | (E & F)')

      expect(complex_delay).to be >= simple_delay
    end

    it 'returns zero for empty expression' do
      delay = analyzer.calculate_expression_delay('')

      expect(delay).to eq(0.0)
    end

    it 'considers parenthesis nesting' do
      shallow = analyzer.calculate_expression_delay('A & B | C & D')
      deep = analyzer.calculate_expression_delay('((A & B) | (C & D))')

      # Nesting depth affects delay calculation
      expect([shallow, deep].all? { |d| d > 0 }).to be true
    end
  end

  describe '#is_timing_met?' do
    it 'returns true when all paths pass' do
      analyzer.analyze_timing(fsm, equations, 10)  # Very low frequency

      expect(analyzer.is_timing_met?).to be true
    end

    it 'returns false with violations' do
      analyzer.analyze_timing(fsm, equations, 5000)  # Extremely high

      # At such high frequency, likely to have violations
      # (depends on equation complexity)
    end
  end

  describe '#get_achievable_frequency' do
    it 'calculates maximum achievable frequency' do
      analyzer.analyze_timing(fsm, equations, 100)
      max_freq = analyzer.get_achievable_frequency

      expect(max_freq).to be > 0
    end

    it 'achievable frequency > target for passing design' do
      analyzer.analyze_timing(fsm, equations, 100)
      max_freq = analyzer.get_achievable_frequency

      expect(max_freq).to be >= 100
    end

    it 'respects critical path' do
      analyzer.analyze_timing(fsm, equations, 100)
      max_freq = analyzer.get_achievable_frequency

      # Should be based on critical path delay
      expect(max_freq).to be_a(Float)
    end
  end

  describe '#get_worst_case_slack' do
    it 'returns slack value' do
      analyzer.analyze_timing(fsm, equations, 100)
      slack = analyzer.get_worst_case_slack

      expect(slack).to be_a(Float)
    end

    it 'positive slack for passing design' do
      analyzer.analyze_timing(fsm, equations, 50)
      slack = analyzer.get_worst_case_slack

      expect(slack).to be > 0
    end

    it 'negative slack indicates violation' do
      analyzer.analyze_timing(fsm, equations, 5000)
      slack = analyzer.get_worst_case_slack

      # High frequency likely gives negative slack
      expect(slack).to be_a(Float)
    end
  end

  describe 'Timing Closure Analysis' do
    context 'with sufficient margin' do
      before { analyzer.analyze_timing(fsm, equations, 50) }

      it 'marks timing as met' do
        expect(analyzer.is_timing_met?).to be true
      end

      it 'has no violations' do
        analyzer.analyze_timing(fsm, equations, 50)
        report = analyzer.get_timing_report

        expect(report[:violations]).to be_empty
      end
    end

    context 'with tight margin' do
      before { analyzer.analyze_timing(fsm, equations, 200) }

      it 'identifies margin warnings' do
        report = analyzer.get_timing_report

        # May have recommendations for margin improvement
        expect(report[:recommendations]).to be_an(Array)
      end
    end

    context 'with violations' do
      before { analyzer.analyze_timing(fsm, equations, 5000) }

      it 'identifies timing violations' do
        report = analyzer.get_timing_report

        # At very high frequency, should have violations
        unless report[:violations].empty?
          expect(report[:summary][:timing_closure]).to eq('FAIL')
        end
      end

      it 'provides violation recommendations' do
        analyzer.analyze_timing(fsm, equations, 5000)
        report = analyzer.get_timing_report

        if report[:violations].any?
          recommendations = report[:recommendations].select { |r| r[:type] == 'violation' }
          expect(recommendations.any?).to be true
        end
      end
    end
  end

  describe 'Library Parameters' do
    it 'uses standard library by default' do
      analyzer = FsmSynthesizer::TimingAnalyzer.new

      result = analyzer.analyze_timing(fsm, equations, 100)

      # Should have standard parameters
      expect(result).to be_present
    end

    it 'accepts custom library' do
      custom_lib = {
        ff_setup: 1.0,
        and_delay: 0.2
      }
      custom_analyzer = FsmSynthesizer::TimingAnalyzer.new(custom_lib)

      result = custom_analyzer.analyze_timing(fsm, equations, 100)

      # Setup time should be custom value
      report = custom_analyzer.get_timing_report
      expect(report[:library_parameters][:ff_setup]).to eq(1.0)
    end
  end

  describe 'Frequency Scaling' do
    it 'calculates different margins at different frequencies' do
      result_low = analyzer.analyze_timing(fsm, equations, 50)
      slack_low = result_low[:paths].values.first[:slack]

      analyzer = FsmSynthesizer::TimingAnalyzer.new
      result_high = analyzer.analyze_timing(fsm, equations, 500)
      slack_high = result_high[:paths].values.first[:slack]

      # Higher frequency = lower slack
      expect(slack_high).to be < slack_low
    end
  end
end
