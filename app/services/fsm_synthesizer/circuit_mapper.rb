# frozen_string_literal: true

module FsmSynthesizer
  class CircuitMapper
    # Map FSM synthesis to CircuitVerse circuit format
    def self.generate_circuit(fsm, flip_flop_type = :d)
      unless fsm.state_bits && fsm.next_state_equations && fsm.output_equations
        raise FsmSynthesizer::GenerationError,
              'Missing synthesis data: run Encoder and EquationGenerator before CircuitMapper'
      end

      # Generate flip-flop excitation equations based on type
      excitation_equations = FsmSynthesizer::FlipFlopEncoder.generate_excitation_equations(fsm, flip_flop_type)

      {
        version: 1,
        metadata: {
          machine_type: fsm.machine_type,
          states: fsm.states.size,
          inputs: fsm.inputs,
          outputs: fsm.outputs,
          flip_flop_type: flip_flop_type.to_s
        },
        components: {
          flip_flops: generate_flip_flops(fsm, flip_flop_type),
          gates: generate_gates(fsm, excitation_equations)
        },
        connections: generate_connections(fsm)
      }
    end

    def self.generate_flip_flops(fsm, flip_flop_type = :d)
      ff_type_str = case flip_flop_type.to_sym
                    when :d
                      'dflipflop'
                    when :jk
                      'jkflipflop'
                    when :sr
                      'srflipflop'
                    else
                      raise FsmSynthesizer::GenerationError, "Unknown flip-flop type: #{flip_flop_type}"
                    end

      (0...fsm.state_bits).map do |idx|
        {
          id: "FF#{idx}",
          type: ff_type_str,
          label: "Q#{idx}",
          metadata: { state_bit: idx, flip_flop_type: flip_flop_type.to_s }
        }
      end
    end

    def self.generate_gates(fsm, excitation_equations)
      gates = []

      # Gates for excitation logic (D, J/K, or S/R)
      excitation_equations.each_with_index do |(eq_id, expr), idx|
        # Extract bit number from equation ID (D0, J0, K0, S0, R0, etc.)
        match = eq_id.to_s.match(/\A([DJKSR])(\d+)\z/)
        unless match
          raise FsmSynthesizer::GenerationError, "Invalid excitation equation ID: #{eq_id}"
        end

        ff_bit = match[2].to_i
        gates << {
          id: "EXG#{idx}",
          type: "logic_block",
          expression: expr,
          label: "Excitation_#{eq_id}",
          input_to: "FF#{ff_bit}"
        }
      end

      # Gates for output logic
      fsm.output_equations.each_with_index do |(out_id, expr), idx|
        gates << {
          id: "OG#{idx}",
          type: "logic_block",
          expression: expr,
          label: "Output_#{out_id}"
        }
      end

      gates
    end

    def self.generate_connections(fsm)
      raise FsmSynthesizer::GenerationError,
            'Connection mapping is not implemented yet. Return explicit edge mappings before using CircuitMapper output.'
    end

    private_class_method :generate_flip_flops, :generate_gates, :generate_connections
  end
end
