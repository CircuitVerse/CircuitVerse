# frozen_string_literal: true

module FsmSynthesizer
  class CircuitMapper
    # Map FSM synthesis to CircuitVerse circuit format
    def self.generate_circuit(fsm)
      unless fsm.state_bits && fsm.next_state_equations && fsm.output_equations
        raise FsmSynthesizer::GenerationError,
              'Missing synthesis data: run Encoder and EquationGenerator before CircuitMapper'
      end

      {
        version: 1,
        metadata: {
          machine_type: fsm.machine_type,
          states: fsm.states.size,
          inputs: fsm.inputs,
          outputs: fsm.outputs
        },
        components: {
          flip_flops: generate_flip_flops(fsm),
          gates: generate_gates(fsm)
        },
        connections: generate_connections(fsm)
      }
    end

    def self.generate_flip_flops(fsm)
      (0...fsm.state_bits).map do |idx|
        {
          id: "FF#{idx}",
          type: "dflipflop",
          label: "Q#{idx}",
          metadata: { state_bit: idx }
        }
      end
    end

    def self.generate_gates(fsm)
      gates = []

      # Gates for next-state logic
      fsm.next_state_equations.each_with_index do |(eq_id, expr), idx|
        bit_index = eq_id.to_s.delete_prefix('D').to_i
        gates << {
          id: "NSG#{idx}",
          type: "logic_block",
          expression: expr,
          label: "NextState_#{eq_id}",
          output_to: "FF#{bit_index}"
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
      # Placeholder for wiring information
      { state_feedback: "FF output to NS gates", input_mapping: fsm.inputs, output_mapping: fsm.outputs }
    end

    private_class_method :generate_flip_flops, :generate_gates, :generate_connections
  end
end
