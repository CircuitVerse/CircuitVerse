require 'rails_helper'

RSpec.describe FsmSynthesizer::InputSynchronizer do
  let(:synchronizer) { described_class.new }

  let(:fsm) do
    fsm = FsmSynthesizer::Base.new
    fsm.states = ['S0', 'S1', 'S2']
    fsm.inputs = ['X', 'Y', 'external_input']
    fsm.outputs = ['Z']
    fsm.transitions = [
      { from: 'S0', to: 'S1', condition: 'X', output: '0' },
      { from: 'S1', to: 'S2', condition: 'Y', output: '1' }
    ]
    fsm.initial_state = 'S0'
    fsm
  end

  describe '#configure_synchronizer' do
    it 'configures a single synchronizer with default parameters' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys'
      )

      expect(config[:input_name]).to eq('external_input')
      expect(config[:src_clock]).to eq('clk_src')
      expect(config[:dest_clock]).to eq('clk_sys')
      expect(config[:sync_type]).to eq('two_flop')
      expect(config[:num_stages]).to eq(2)
    end

    it 'configures synchronizer with custom sync type' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'gray'
      )

      expect(config[:sync_type]).to eq('gray')
    end

    it 'configures synchronizer with multiple stages' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        num_stages: 4
      )

      expect(config[:num_stages]).to eq(4)
    end

    it 'stores synchronizer in internal hash' do
      synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys'
      )

      expect(synchronizer.synchronizers).to have_key('external_input')
    end

    it 'calculates metastability margin' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        num_stages: 2
      )

      expect(config[:metastability_msat]).to be_a(Float)
      expect(config[:metastability_msat]).to be_positive
    end

    it 'calculates settling time' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys'
      )

      expect(config[:settling_time_ns]).to be_a(Float)
      expect(config[:settling_time_ns]).to be_positive
    end

    it 'raises error for non-existent input' do
      expect do
        synchronizer.configure_synchronizer(
          fsm,
          input_name: 'non_existent',
          src_clock: 'clk_src',
          dest_clock: 'clk_sys'
        )
      end.to raise_error(FsmSynthesizer::ValidationError)
    end

    it 'raises error for invalid sync type' do
      expect do
        synchronizer.configure_synchronizer(
          fsm,
          input_name: 'external_input',
          src_clock: 'clk_src',
          dest_clock: 'clk_sys',
          sync_type: 'invalid_type'
        )
      end.to raise_error(FsmSynthesizer::ValidationError)
    end

    it 'raises error for invalid num_stages' do
      expect do
        synchronizer.configure_synchronizer(
          fsm,
          input_name: 'external_input',
          src_clock: 'clk_src',
          dest_clock: 'clk_sys',
          num_stages: 1
        )
      end.to raise_error(FsmSynthesizer::ValidationError)
    end

    it 'supports two_flop synchronizer type' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'two_flop'
      )

      expect(config[:sync_type]).to eq('two_flop')
    end

    it 'supports gray synchronizer type' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'gray'
      )

      expect(config[:sync_type]).to eq('gray')
    end

    it 'supports pulse synchronizer type' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'pulse'
      )

      expect(config[:sync_type]).to eq('pulse')
    end

    it 'supports handshake synchronizer type' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'handshake'
      )

      expect(config[:sync_type]).to eq('handshake')
    end
  end

  describe '#configure_synchronizers' do
    it 'configures multiple synchronizers at once' do
      configs = [
        { input_name: 'X', src_clock: 'clk_src', dest_clock: 'clk_sys' },
        { input_name: 'Y', src_clock: 'clk_src', dest_clock: 'clk_sys' }
      ]

      synchronizer.configure_synchronizers(fsm, configs)

      expect(synchronizer.synchronizers).to have_key('X')
      expect(synchronizer.synchronizers).to have_key('Y')
    end

    it 'returns all configured synchronizers' do
      configs = [
        { input_name: 'X', src_clock: 'clk_src', dest_clock: 'clk_sys', sync_type: 'two_flop' },
        { input_name: 'Y', src_clock: 'clk_src', dest_clock: 'clk_sys', sync_type: 'gray' }
      ]

      result = synchronizer.configure_synchronizers(fsm, configs)

      expect(result).to have_key('X')
      expect(result).to have_key('Y')
      expect(result['X'][:sync_type]).to eq('two_flop')
      expect(result['Y'][:sync_type]).to eq('gray')
    end

    it 'applies custom sync_type to multiple inputs' do
      configs = [
        { input_name: 'X', src_clock: 'clk_src', dest_clock: 'clk_sys', sync_type: 'pulse' },
        { input_name: 'Y', src_clock: 'clk_src', dest_clock: 'clk_sys', sync_type: 'pulse' }
      ]

      synchronizer.configure_synchronizers(fsm, configs)

      expect(synchronizer.synchronizers['X'][:sync_type]).to eq('pulse')
      expect(synchronizer.synchronizers['Y'][:sync_type]).to eq('pulse')
    end
  end

  describe '#generate_sync_equations' do
    before do
      synchronizer.configure_synchronizer(
        fsm,
        input_name: 'X',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys'
      )
    end

    it 'generates basic synchronized equations' do
      input_eqs = {
        next_state: 'X & ~Q',
        output: 'X | Y'
      }

      result = synchronizer.generate_sync_equations(fsm, input_eqs)

      expect(result).to be_a(Hash)
    end

    it 'preserves equation structure' do
      input_eqs = {
        D0: '(X & Q0) | (~X & Q1)'
      }

      result = synchronizer.generate_sync_equations(fsm, input_eqs)

      expect(result).to have_key(:D0)
    end

    it 'handles equations without synchronized inputs' do
      input_eqs = {
        D0: '(Q0 | Q1) & Y'
      }

      result = synchronizer.generate_sync_equations(fsm, input_eqs)

      expect(result[:D0]).to eq('(Q0 | Q1) & Y')
    end
  end

  describe '#get_synchronizer_circuits' do
    before do
      synchronizer.configure_synchronizer(
        fsm,
        input_name: 'X',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'two_flop'
      )
      synchronizer.configure_synchronizer(
        fsm,
        input_name: 'Y',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'gray'
      )
    end

    it 'generates circuit specifications for all synchronizers' do
      circuits = synchronizer.get_synchronizer_circuits

      expect(circuits).to have_key('X')
      expect(circuits).to have_key('Y')
    end

    it 'generates two_flop circuit with correct structure' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['X']

      expect(circuit[:type]).to eq('two_flop_synchronizer')
      expect(circuit[:description]).to include('stage')
      expect(circuit).to have_key(:components)
    end

    it 'generates gray circuit with correct structure' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['Y']

      expect(circuit[:type]).to eq('gray_code_synchronizer')
      expect(circuit).to have_key(:components)
    end

    it 'includes timing information in circuits' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['X']

      expect(circuit[:timing]).to have_key(:metastability_margin_sigma)
      expect(circuit[:timing]).to have_key(:settling_time_ns)
      expect(circuit[:timing]).to have_key(:max_freq_mhz)
    end
  end

  describe '#get_synchronizer' do
    before do
      synchronizer.configure_synchronizer(
        fsm,
        input_name: 'external_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys'
      )
    end

    it 'retrieves configured synchronizer by name' do
      config = synchronizer.get_synchronizer('external_input')

      expect(config).not_to be_nil
      expect(config[:input_name]).to eq('external_input')
    end

    it 'returns nil for non-existent synchronizer' do
      config = synchronizer.get_synchronizer('non_existent')

      expect(config).to be_nil
    end
  end

  describe 'Two-Flop Synchronizer Circuit Generation' do
    before do
      synchronizer.configure_synchronizer(
        fsm,
        input_name: 'ext_sig',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'two_flop',
        num_stages: 2
      )
    end

    it 'creates flip-flop chain with correct number of stages' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['ext_sig']
      ff_chain = circuit[:components][0]

      expect(ff_chain[:type]).to eq('flip_flop_chain')
      expect(ff_chain[:stages]).to eq(2)
      expect(ff_chain[:flip_flops].length).to eq(2)
    end

    it 'properly chains synchronizer flip-flops' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['ext_sig']
      ff_chain = circuit[:components][0]
      ffs = ff_chain[:flip_flops]

      expect(ffs[0][:input]).to eq('ext_sig')
      expect(ffs[0][:output]).to eq('SYNC1')
      expect(ffs[1][:input]).to eq('SYNC1')
      expect(ffs[1][:output]).to eq('SYNC2')
    end

    it 'includes reliability metrics' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['ext_sig']

      expect(circuit[:reliability]).to have_key(:mtbf_years)
      expect(circuit[:reliability]).to have_key(:hazard_probability)
    end
  end

  describe 'Gray Code Synchronizer Circuit Generation' do
    before do
      synchronizer.configure_synchronizer(
        fsm,
        input_name: 'data_bus',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'gray',
        num_stages: 2
      )
    end

    it 'includes gray encoder component' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['data_bus']
      components = circuit[:components]

      expect(components.any? { |c| c[:type] == 'gray_encoder' }).to be true
    end

    it 'includes gray decoder component' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['data_bus']
      components = circuit[:components]

      expect(components.any? { |c| c[:type] == 'gray_decoder' }).to be true
    end

    it 'includes synchronizer chain component' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['data_bus']
      components = circuit[:components]

      expect(components.any? { |c| c[:type] == 'synchronizer_chain' }).to be true
    end
  end

  describe 'Pulse Synchronizer Circuit Generation' do
    before do
      synchronizer.configure_synchronizer(
        fsm,
        input_name: 'pulse_sig',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'pulse',
        num_stages: 2
      )
    end

    it 'includes pulse detector component' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['pulse_sig']
      components = circuit[:components]

      expect(components.any? { |c| c[:type] == 'pulse_detector' }).to be true
    end

    it 'includes toggle logic component' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['pulse_sig']
      components = circuit[:components]

      expect(components.any? { |c| c[:type] == 'toggle_logic' }).to be true
    end

    it 'includes edge detector component' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['pulse_sig']
      components = circuit[:components]

      expect(components.any? { |c| c[:type] == 'edge_detector' }).to be true
    end
  end

  describe 'Handshake Synchronizer Circuit Generation' do
    before do
      synchronizer.configure_synchronizer(
        fsm,
        input_name: 'async_input',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'handshake',
        num_stages: 2
      )
    end

    it 'includes async FIFO structure' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['async_input']

      expect(circuit[:type]).to eq('handshake_fifo')
    end

    it 'includes write logic component' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['async_input']
      components = circuit[:components]

      expect(components.any? { |c| c[:type] == 'write_logic' }).to be true
    end

    it 'includes FIFO memory component' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['async_input']
      components = circuit[:components]

      expect(components.any? { |c| c[:type] == 'fifo_memory' }).to be true
    end

    it 'includes pointer synchronization' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['async_input']
      components = circuit[:components]

      expect(components.any? { |c| c[:type] == 'pointers_sync' }).to be true
    end

    it 'includes read logic component' do
      circuits = synchronizer.get_synchronizer_circuits
      circuit = circuits['async_input']
      components = circuit[:components]

      expect(components.any? { |c| c[:type] == 'read_logic' }).to be true
    end
  end

  describe 'Metastability Margin Calculations' do
    it 'calculates margin for two_flop with 2 stages' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'X',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'two_flop',
        num_stages: 2
      )

      expect(config[:metastability_msat]).to be_a(Float)
      expect(config[:metastability_msat]).to be_positive
    end

    it 'improves margin with more stages' do
      config2 = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'X',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'two_flop',
        num_stages: 2
      )

      config4 = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'Y',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'two_flop',
        num_stages: 4
      )

      expect(config4[:metastability_msat]).to be < config2[:metastability_msat]
    end

    it 'gives better margin for gray_sync vs two_flop' do
      config_two = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'X',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'two_flop',
        num_stages: 2
      )

      config_gray = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'Y',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'gray',
        num_stages: 2
      )

      expect(config_gray[:metastability_msat]).to be > config_two[:metastability_msat]
    end
  end

  describe 'Settling Time Calculations' do
    it 'calculates settling time for synchronizer' do
      config = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'X',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'two_flop'
      )

      expect(config[:settling_time_ns]).to be_positive
    end

    it 'settling time increases with more stages' do
      config2 = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'X',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'two_flop',
        num_stages: 2
      )

      config4 = synchronizer.configure_synchronizer(
        fsm,
        input_name: 'Y',
        src_clock: 'clk_src',
        dest_clock: 'clk_sys',
        sync_type: 'two_flop',
        num_stages: 4
      )

      expect(config4[:settling_time_ns]).to be > config2[:settling_time_ns]
    end
  end
end
