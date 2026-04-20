# Boolean Equation Generation Service
module FsmSynthesizer
  class EquationGenerator
    # Generate next-state equations from FSM
    def self.generate_next_state_equations(fsm)
      equations = {}

      fsm.state_bits.times do |bit_index|
        # Collect all transitions where next state has 1 at this bit position
        minterms = []

        fsm.transitions.each do |transition|
          from_state = transition[:from]
          input_symbol = transition[:input]
          to_state = transition[:to]

          from_bits = fsm.state_encoding[from_state]
          to_bits = fsm.state_encoding[to_state]

          if to_bits[bit_index] == 1
            input_idx = fsm.inputs.index(input_symbol)
            minterms << { bits: from_bits, input_idx: }
          end
        end

        # Generate SOP expression (simplified placeholder)
        equations["D#{bit_index}"] = generate_sop_expression(minterms, fsm.state_bits, fsm.inputs.size)
      end

      fsm.next_state_equations = equations
      equations
    end

    # Generate output equations from FSM
    def self.generate_output_equations(fsm)
      equations = {}

      fsm.outputs.each do |output_symbol|
        minterms = []

        if fsm.machine_type == :moore
          # Moore: output depends only on current state
          fsm.states.each do |state|
            if fsm.state_outputs[state[:id]] == output_symbol
              bits = fsm.state_encoding[state[:id]]
              minterms << { bits:, input_idx: nil }
            end
          end
        else
          # Mealy: output depends on state and input
          fsm.transitions.each do |transition|
            next unless transition[:output] == output_symbol

            from_bits = fsm.state_encoding[transition[:from]]
            input_idx = fsm.inputs.index(transition[:input])
            minterms << { bits: from_bits, input_idx: }
          end
        end

        equations[output_symbol.to_s] = generate_sop_expression(minterms, fsm.state_bits, fsm.inputs.size)
      end

      fsm.output_equations = equations
      equations
    end

    private

    # Placeholder SOP generation (canonical form for now)
    def self.generate_sop_expression(minterms, state_bits, input_bits)
      return "0" if minterms.empty?

      terms = minterms.map do |minterm|
        state_part = minterm[:bits].map.with_index do |bit, idx|
          bit == 1 ? "Q#{idx}" : "~Q#{idx}"
        end.join(" & ")

        if minterm[:input_idx].nil?
          state_part
        else
          input_part = (0...input_bits).map do |idx|
            idx == minterm[:input_idx] ? "X#{idx}" : "~X#{idx}"
          end
          "#{state_part} & #{input_part.join(' & ')}"
        end
      end

      terms.join(" | ")
    end
  end
end
