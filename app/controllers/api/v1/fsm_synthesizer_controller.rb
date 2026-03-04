# frozen_string_literal: true

module Api
  module V1
    class FsmSynthesizerController < BaseController
      # POST /api/v1/fsm_synthesize
      # Synthesizes an FSM from user input into circuit components
      # 
      # Request body:
      # {
      #   "fsm_data": "JSON or CSV FSM definition",
      #   "format": "json" or "csv",
      #   "encoding": "binary", "one_hot", or "gray" (optional, default: binary),
      #   "flip_flop_type": "d" or "jk" or "sr" (optional, default: d),
      #   "reset_type": "none", "synchronous", or "asynchronous" (optional, default: none),
      #   "reset_state": "S0" (optional, default: initial state),
      #   "sync_inputs": [
      #     {
      #       "input_name": "external_input",
      #       "src_clock": "clk_src",
      #       "dest_clock": "clk_sys",
      #       "sync_type": "two_flop|gray|pulse|handshake" (optional, default: two_flop),
      #       "num_stages": 2 (optional, default: 2)
      #     }
      #   ] (optional)
      # }
      #
      # Response (includes new fields when sync_inputs are configured):
      # {
      #   "machine_type": "moore|mealy",
      #   "states": ["S0", "S1", ...],
      #   "inputs": ["0", "1", ...],
      #   "outputs": ["z", "w", ...],
      #   "state_encoding": { "S0": [0, 0], "S1": [0, 1], ... },
      #   "flip_flop_type": "d",
      #   "excitation_equations": { "D0": "~Q0 & X", "D1": "Q0 & X", ... },
      #   "output_equations": { "z": "Q0 & Q1", ... },
      #   "circuit": { ... },
      #   "synchronizers": {  # NEW if sync_inputs provided
      #     "external_input": {
      #       "type": "two_flop_synchronizer",
      #       "sync_type": "two_flop",
      #       "num_stages": 2,
      #       "metastability_margin": 3.5,
      #       ...
      #     }
      #   },
      #   "metastability_analysis": {  # NEW if sync_inputs provided
      #     "overall_risk": "low|medium|high",
      #     "synchronized_inputs": ["external_input"],
      #     "unsynchronized_inputs": [],
      #     "at_risk_inputs": [],
      #     ...
      #   }
      # }
      def synthesize
        # Validate input parameters
        validate_synthesis_params

        # Parse FSM from input
        fsm = parse_fsm_input

        # Validate FSM structure (determinism, completeness)
        FsmSynthesizer::Validator.validate(fsm)

        # Apply encoding strategy
        encoding_type = synthesis_params[:encoding] || 'binary'
        case encoding_type
        when 'binary'
          FsmSynthesizer::Encoder.encode_binary(fsm)
        when 'one_hot'
          FsmSynthesizer::Encoder.encode_one_hot(fsm)
        when 'gray'
          FsmSynthesizer::Encoder.encode_gray(fsm)
        else
          raise FsmSynthesizer::ValidationError, "Unknown encoding type: #{encoding_type}"
        end

        # Generate equations
        FsmSynthesizer::EquationGenerator.generate_next_state_equations(fsm)
        FsmSynthesizer::EquationGenerator.generate_output_equations(fsm)

        # Select flip-flop type and generate excitation equations
        flip_flop_type = synthesis_params[:flip_flop_type] || 'd'
        excitation_equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(fsm, flip_flop_type)

        # Configure reset if specified
        reset_type = synthesis_params[:reset_type] || 'none'
        if reset_type != 'none'
          reset_state = synthesis_params[:reset_state]
          FsmSynthesizer::ResetController.configure_reset(fsm, reset_type.to_sym, reset_state)
        end

        # Configure input synchronizers if specified
        synchronizers = {}
        metastability_analysis = nil
        sync_inputs = synthesis_params[:sync_inputs]
        
        if sync_inputs.present?
          synchronizer_service = FsmSynthesizer::InputSynchronizer.new
          synchronizer_service.configure_synchronizers(fsm, sync_inputs)
          synchronizers = synchronizer_service.get_synchronizer_circuits

          # Analyze metastability hazards
          analyzer = FsmSynthesizer::MetastabilityAnalyzer.new
          analysis_crossings = sync_inputs.map do |config|
            {
              input_name: config[:input_name],
              src_clock: config[:src_clock],
              dest_clock: config[:dest_clock],
              freq_src_mhz: config.fetch(:freq_src_mhz, 100),
              freq_dest_mhz: config.fetch(:freq_dest_mhz, 100)
            }
          end
          analyzer.analyze_crossings(fsm, analysis_crossings)
          
          # Get synchronized equations if any inputs are configured
          if synchronizers.any?
            sync_eq_service = FsmSynthesizer::InputSynchronizer.new
            sync_eq_service.synchronizers = synchronizer_service.synchronizers
            # Note: In production, would apply sync equations to excitation_equations here
          end
          
          # Build metastability analysis report
          metastability_analysis = analyzer.assess_synchronizer_safety(fsm, synchronizer_service.synchronizers)
        end

        # Generate circuit structure (with optional reset circuit)
        include_reset = reset_type != 'none'
        circuit = FsmSynthesizer::CircuitMapper.generate_circuit(fsm, flip_flop_type, include_reset)

        # Generate state diagram if requested
        diagram = nil
        diagram_data = nil
        if synthesis_params[:include_diagram] != false
          diagram_layout = synthesis_params[:diagram_layout] || 'hierarchy'
          diagram_generator = FsmSynthesizer::StateDiagramGenerator.new
          diagram = diagram_generator.generate_diagram(fsm, layout: diagram_layout)
          diagram_data = diagram_generator.to_hash(diagram)
        end

        # Optimize equations if requested
        optimization_report = nil
        optimized_excitation_equations = excitation_equations
        if synthesis_params[:include_optimization] != false && synthesis_params[:optimization_level] != 'none'
          optimization_level = synthesis_params[:optimization_level] || 'basic'
          optimizer = FsmSynthesizer::EquationOptimizer.new
          optimized_excitation_equations = optimizer.optimize_equations(fsm, excitation_equations, aggressive: optimization_level == 'aggressive')
          optimization_report = optimizer.get_optimization_report
        end

        # Analyze timing if requested
        timing_analysis_report = nil
        if synthesis_params[:include_timing] != false
          clock_freq_mhz = (synthesis_params[:clock_freq_mhz] || 100).to_f
          timing_analyzer = FsmSynthesizer::TimingAnalyzer.new
          timing_analyzer.analyze_timing(fsm, optimized_excitation_equations, clock_freq_mhz)
          timing_analysis_report = timing_analyzer.get_timing_report
        end

        # Build response
        response_data = {
          machine_type: fsm.machine_type,
          states: fsm.states.map { |s| s[:id] },
          inputs: fsm.inputs,
          outputs: fsm.outputs,
          state_encoding: fsm.state_encoding,
          flip_flop_type: flip_flop_type,
          excitation_equations: optimized_excitation_equations,
          output_equations: fsm.output_equations,
          circuit:
        }

        # Add diagram data if generated
        response_data[:diagram] = diagram_data if diagram_data.present?

        # Add optimization report if generated
        response_data[:optimization_report] = optimization_report if optimization_report.present?

        # Add timing analysis if performed
        response_data[:timing_analysis] = timing_analysis_report if timing_analysis_report.present?

        # Add reset info if configured
        if include_reset
          response_data[:reset_config] = {
            reset_type: reset_type,
            reset_state: fsm.reset_state
          }
        end

        # Add synchronizer info if configured
        if synchronizers.any?
          response_data[:synchronizers] = synchronizers
          response_data[:metastability_analysis] = metastability_analysis
        end

        render json: response_data, status: :ok
      rescue FsmSynthesizer::ValidationError => e
        api_error(status: 422, errors: e.message)
      rescue FsmSynthesizer::EncodingError => e
        api_error(status: 422, errors: e.message)
      rescue FsmSynthesizer::GenerationError => e
        api_error(status: 422, errors: e.message)
      rescue StandardError => e
        api_error(status: 400, errors: "Synthesis failed: #{e.message}")
      end

      private

      def synthesis_params
        params.require(:fsm_data)
        @synthesis_params ||= params.permit(:fsm_data, :format, :encoding, :flip_flop_type, :reset_type, :reset_state, :clock_freq_mhz, :diagram_layout, :optimization_level, :include_diagram, :include_optimization, :include_timing, sync_inputs: [:input_name, :src_clock, :dest_clock, :sync_type, :num_stages, :freq_src_mhz, :freq_dest_mhz])
      end

      def validate_synthesis_params
        fsm_data = synthesis_params[:fsm_data]
        format = synthesis_params[:format]
        flip_flop_type = synthesis_params[:flip_flop_type]
        encoding = synthesis_params[:encoding]
        reset_type = synthesis_params[:reset_type]
        sync_inputs = synthesis_params[:sync_inputs]
        clock_freq_mhz = synthesis_params[:clock_freq_mhz]
        diagram_layout = synthesis_params[:diagram_layout]
        optimization_level = synthesis_params[:optimization_level]

        raise FsmSynthesizer::ValidationError, 'fsm_data is required' if fsm_data.blank?
        raise FsmSynthesizer::ValidationError, 'format is required' if format.blank?
        raise FsmSynthesizer::ValidationError, "Invalid format: #{format}" unless %w[json csv].include?(format)
        if flip_flop_type && !%w[d jk sr].include?(flip_flop_type)
          raise FsmSynthesizer::ValidationError, "Invalid flip-flop type: #{flip_flop_type}"
        end
        if encoding && !%w[binary one_hot gray].include?(encoding)
          raise FsmSynthesizer::ValidationError, "Invalid encoding type: #{encoding}"
        end
        if reset_type && !%w[none synchronous asynchronous].include?(reset_type)
          raise FsmSynthesizer::ValidationError, "Invalid reset type: #{reset_type}"
        end
        if clock_freq_mhz && (!clock_freq_mhz.to_f.positive?)
          raise FsmSynthesizer::ValidationError, "clock_freq_mhz must be a positive number"
        end
        if diagram_layout && !%w[hierarchy circle grid].include?(diagram_layout)
          raise FsmSynthesizer::ValidationError, "Invalid diagram_layout: #{diagram_layout}. Must be: hierarchy, circle, or grid"
        end
        if optimization_level && !%w[none basic aggressive].include?(optimization_level)
          raise FsmSynthesizer::ValidationError, "Invalid optimization_level: #{optimization_level}. Must be: none, basic, or aggressive"
        end
        if sync_inputs.present?
          validate_sync_inputs(sync_inputs)
        end
      end

      def validate_sync_inputs(sync_inputs)
        valid_sync_types = ['two_flop', 'gray', 'pulse', 'handshake']

        sync_inputs.each_with_index do |config, index|
          unless config[:input_name].present?
            raise FsmSynthesizer::ValidationError, "sync_inputs[#{index}]: input_name is required"
          end
          unless config[:src_clock].present?
            raise FsmSynthesizer::ValidationError, "sync_inputs[#{index}]: src_clock is required"
          end
          unless config[:dest_clock].present?
            raise FsmSynthesizer::ValidationError, "sync_inputs[#{index}]: dest_clock is required"
          end
          if config[:sync_type] && !valid_sync_types.include?(config[:sync_type])
            raise FsmSynthesizer::ValidationError, 
                  "sync_inputs[#{index}]: invalid sync_type '#{config[:sync_type]}'. Must be: #{valid_sync_types.join(', ')}"
          end
          if config[:num_stages] && (!config[:num_stages].is_a?(Integer) || config[:num_stages] < 2)
            raise FsmSynthesizer::ValidationError,
                  "sync_inputs[#{index}]: num_stages must be integer >= 2"
          end
        end
      end

      def parse_fsm_input
        fsm_data = synthesis_params[:fsm_data]
        format = synthesis_params[:format]

        case format
        when 'json'
          FsmSynthesizer::Parser.parse_json(fsm_data)
        when 'csv'
          FsmSynthesizer::Parser.parse_csv(fsm_data)
        else
          raise FsmSynthesizer::ValidationError, "Unknown format: #{format}"
        end
      end
    end
  end
end
