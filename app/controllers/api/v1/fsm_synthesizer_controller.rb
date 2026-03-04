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
      #   "reset_state": "S0" (optional, default: initial state)
      # }
      #
      # Response:
      # {
      #   "machine_type": "moore|mealy",
      #   "states": ["S0", "S1", ...],
      #   "inputs": ["0", "1", ...],
      #   "outputs": ["z", "w", ...],
      #   "state_encoding": { "S0": [0, 0], "S1": [0, 1], ... },
      #   "flip_flop_type": "d",
      #   "excitation_equations": { "D0": "~Q0 & X", "D1": "Q0 & X", ... },
      #   "output_equations": { "z": "Q0 & Q1", ... },
      #   "circuit": {
      #     "version": 1,
      #     "metadata": { ... },
      #     "components": { ... },
      #     "connections": { ... }
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

        # Generate circuit structure (with optional reset circuit)
        include_reset = reset_type != 'none'
        circuit = FsmSynthesizer::CircuitMapper.generate_circuit(fsm, flip_flop_type, include_reset)

        # Build response
        response_data = {
          machine_type: fsm.machine_type,
          states: fsm.states.map { |s| s[:id] },
          inputs: fsm.inputs,
          outputs: fsm.outputs,
          state_encoding: fsm.state_encoding,
          flip_flop_type: flip_flop_type,
          excitation_equations:,
          output_equations: fsm.output_equations,
          circuit:
        }

        # Add reset info if configured
        if include_reset
          response_data[:reset_config] = {
            reset_type: reset_type,
            reset_state: fsm.reset_state
          }
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
        @synthesis_params ||= params.permit(:fsm_data, :format, :encoding, :flip_flop_type, :reset_type, :reset_state)
      end

      def validate_synthesis_params
        fsm_data = synthesis_params[:fsm_data]
        format = synthesis_params[:format]
        flip_flop_type = synthesis_params[:flip_flop_type]
        encoding = synthesis_params[:encoding]
        reset_type = synthesis_params[:reset_type]

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
