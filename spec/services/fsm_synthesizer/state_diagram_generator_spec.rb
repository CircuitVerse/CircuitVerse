require 'rails_helper'

RSpec.describe FsmSynthesizer::StateDiagramGenerator do
  let(:generator) { described_class.new }

  let(:fsm) do
    fsm = FsmSynthesizer::Base.new
    fsm.states = ['S0', 'S1', 'S2', 'S3']
    fsm.inputs = ['X', 'Y']
    fsm.outputs = ['Z']
    fsm.transitions = [
      { from: 'S0', to: 'S1', condition: 'X' },
      { from: 'S0', to: 'S0', condition: '~X' },
      { from: 'S1', to: 'S2', condition: 'Y' },
      { from: 'S1', to: 'S0', condition: '~Y' },
      { from: 'S2', to: 'S3', condition: 'X & Y' },
      { from: 'S2', to: 'S0', condition: '~(X & Y)' },
      { from: 'S3', to: 'S0', condition: '1' }
    ]
    fsm.initial_state = 'S0'
    fsm.machine_type = 'moore'
    fsm.state_encoding = { 'S0' => [0, 0], 'S1' => [0, 1], 'S2' => [1, 0], 'S3' => [1, 1] }
    fsm.state_outputs = { 'S0' => '0', 'S1' => '0', 'S2' => '0', 'S3' => '1' }
    fsm
  end

  describe '#generate_diagram' do
    it 'generates diagram with all states' do
      diagram = generator.generate_diagram(fsm)

      expect(diagram[:states].keys).to match_array(['S0', 'S1', 'S2', 'S3'])
    end

    it 'marks initial state' do
      diagram = generator.generate_diagram(fsm)

      expect(diagram[:states]['S0'][:is_initial]).to be true
      expect(diagram[:states]['S1'][:is_initial]).to be false
    end

    it 'includes state encodings' do
      diagram = generator.generate_diagram(fsm, include_encoding: true)

      expect(diagram[:states]['S0'][:encoding]).to eq([0, 0])
      expect(diagram[:states]['S1'][:encoding]).to eq([0, 1])
    end

    it 'includes state outputs for Moore machine' do
      diagram = generator.generate_diagram(fsm, include_outputs: true)

      expect(diagram[:states]['S0'][:output]).to eq('0')
      expect(diagram[:states]['S3'][:output]).to eq('1')
    end

    it 'generates all transitions' do
      diagram = generator.generate_diagram(fsm)

      expect(diagram[:transitions].length).to eq(fsm.transitions.length)
    end

    it 'includes transition conditions' do
      diagram = generator.generate_diagram(fsm)

      x_to_s1 = diagram[:transitions].find { |t| t[:from] == 'S0' && t[:to] == 'S1' }
      expect(x_to_s1[:condition]).to eq('X')
    end

    it 'identifies self-loop transitions' do
      diagram = generator.generate_diagram(fsm)

      self_loop = diagram[:transitions].find { |t| t[:from] == 'S0' && t[:to] == 'S0' }
      expect(self_loop[:is_loop]).to be true
    end

    it 'generates metadata' do
      diagram = generator.generate_diagram(fsm)

      expect(diagram[:metadata][:machine_type]).to eq('moore')
      expect(diagram[:metadata][:num_states]).to eq(4)
      expect(diagram[:metadata][:num_transitions]).to eq(7)
    end

    it 'supports hierarchical layout' do
      diagram = generator.generate_diagram(fsm, layout: 'hierarchy')

      expect(diagram[:layout]).to eq('hierarchy')
      expect(diagram[:states]['S0'][:x]).to be_present
      expect(diagram[:states]['S0'][:y]).to be_present
    end

    it 'supports circular layout' do
      diagram = generator.generate_diagram(fsm, layout: 'circle')

      expect(diagram[:layout]).to eq('circle')
      # All states should have positions
      diagram[:states].each do |_, state|
        expect(state[:x]).to be_present
        expect(state[:y]).to be_present
      end
    end

    it 'supports grid layout' do
      diagram = generator.generate_diagram(fsm, layout: 'grid')

      expect(diagram[:layout]).to eq('grid')
      diagram[:states].each do |_, state|
        expect(state[:x]).to be_present
        expect(state[:y]).to be_present
      end
    end

    it 'adds control points to transitions' do
      diagram = generator.generate_diagram(fsm, layout: 'hierarchy')

      diagram[:transitions].each do |trans|
        expect(trans[:control_points]).to be_an(Array)
      end
    end
  end

  describe '#to_graphviz' do
    it 'generates valid GraphViz DOT format' do
      diagram = generator.generate_diagram(fsm)
      dot = generator.to_graphviz(diagram)

      expect(dot).to include('digraph FSM')
      expect(dot).to include('rankdir=LR')
      expect(dot).to include('S0')
      expect(dot).to include('S1')
    end

    it 'includes initial state transition' do
      diagram = generator.generate_diagram(fsm)
      dot = generator.to_graphviz(diagram)

      expect(dot).to include('initial ->')
    end

    it 'includes all transitions' do
      diagram = generator.generate_diagram(fsm)
      dot = generator.to_graphviz(diagram)

      expect(dot).to include('-> "S1"')
      expect(dot).to include('-> "S2"')
    end

    it 'includes condition labels' do
      diagram = generator.generate_diagram(fsm)
      dot = generator.to_graphviz(diagram)

      expect(dot).to include('[label="X')
      expect(dot).to include('[label="Y')
    end

    it 'marks initial state with green' do
      diagram = generator.generate_diagram(fsm)
      dot = generator.to_graphviz(diagram)

      expect(dot).to include('lightgreen')
    end

    it 'raises error without generated diagram' do
      expect do
        generator.to_graphviz
      end.to raise_error(RuntimeError)
    end
  end

  describe '#to_json' do
    it 'generates valid JSON' do
      diagram = generator.generate_diagram(fsm)
      json = generator.to_json(diagram)

      expect { JSON.parse(json) }.not_to raise_error
    end

    it 'includes all diagram data' do
      diagram = generator.generate_diagram(fsm)
      json = generator.to_json(diagram)
      parsed = JSON.parse(json)

      expect(parsed['states']).to be_present
      expect(parsed['transitions']).to be_present
      expect(parsed['metadata']).to be_present
    end

    it 'includes FSM type' do
      diagram = generator.generate_diagram(fsm)
      json = generator.to_json(diagram)
      parsed = JSON.parse(json)

      expect(parsed['fsm_type']).to eq('moore')
    end
  end

  describe '#to_hash' do
    it 'returns hash structure' do
      diagram = generator.generate_diagram(fsm)
      hash = generator.to_hash(diagram)

      expect(hash).to be_a(Hash)
      expect(hash[:fsm_type]).to eq('moore')
      expect(hash[:states]).to be_present
      expect(hash[:transitions]).to be_present
    end

    it 'includes initial state' do
      diagram = generator.generate_diagram(fsm)
      hash = generator.to_hash(diagram)

      expect(hash[:initial_state]).to eq('S0')
    end
  end

  describe '#get_state_positions' do
    it 'returns state positioning' do
      diagram = generator.generate_diagram(fsm, layout: 'hierarchy')
      positions = generator.get_state_positions(diagram)

      expect(positions).to have_key('S0')
      expect(positions['S0']).to have_key(:x)
      expect(positions['S0']).to have_key(:y)
      expect(positions['S0']).to have_key(:radius)
    end

    it 'all states have positions' do
      diagram = generator.generate_diagram(fsm, layout: 'circle')
      positions = generator.get_state_positions(diagram)

      fsm.states.each do |state|
        expect(positions).to have_key(state)
        expect(positions[state][:x]).to be_a(Numeric)
        expect(positions[state][:y]).to be_a(Numeric)
      end
    end
  end

  describe '#get_transition_paths' do
    it 'returns transition paths' do
      diagram = generator.generate_diagram(fsm)
      paths = generator.get_transition_paths(diagram)

      expect(paths).to be_a(Hash)
      expect(paths.length).to be > 0
    end

    it 'identifies self-loop paths' do
      diagram = generator.generate_diagram(fsm)
      paths = generator.get_transition_paths(diagram)

      self_loop_path = paths.values.find { |p| p[:is_loop] }
      expect(self_loop_path).to be_present
    end

    it 'includes control points' do
      diagram = generator.generate_diagram(fsm, layout: 'hierarchy')
      paths = generator.get_transition_paths(diagram)

      paths.each_value do |path|
        expect(path[:control_points]).to be_an(Array)
      end
    end
  end

  describe 'Determinism Detection' do
    it 'detects deterministic FSM' do
      diagram = generator.generate_diagram(fsm)

      expect(diagram[:metadata][:deterministic]).to be true
    end

    it 'detects nondeterministic FSM' do
      fsm.transitions << { from: 'S0', to: 'S2', condition: 'X' }  # Conflict with S0->S1 on X
      diagram = generator.generate_diagram(fsm)

      expect(diagram[:metadata][:deterministic]).to be false
    end
  end

  describe 'Reachability Analysis' do
    it 'counts reachable states' do
      diagram = generator.generate_diagram(fsm)

      expect(diagram[:metadata][:reachable_states]).to eq(4)
    end

    it 'identifies unreachable states' do
      # Add unreachable state
      fsm.states << 'S4'
      diagram = generator.generate_diagram(fsm)

      expect(diagram[:metadata][:unreachable_states]).to include('S4')
    end

    it 'empty unreachable list when all reachable' do
      diagram = generator.generate_diagram(fsm)

      expect(diagram[:metadata][:unreachable_states]).to be_empty
    end
  end

  describe 'State Acceptance Detection' do
    it 'identifies accepting states' do
      diagram = generator.generate_diagram(fsm)

      # S3 has no outgoing transitions (except to S0 which has no output effect)
      accepting = diagram[:states].select { |_, s| s[:is_accepting] }
      expect(accepting.length).to be > 0
    end
  end
end
