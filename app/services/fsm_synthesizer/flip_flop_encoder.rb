# frozen_string_literal: true

module FsmSynthesizer
  # Flip-flop type definitions and excitation equation generation
  class FlipFlopEncoder
    # Supported flip-flop types
    FF_TYPES = {
      d: 'D Flip-Flop',
      jk: 'JK Flip-Flop',
      sr: 'SR Flip-Flop'
    }.freeze

    # Generate excitation equations for next-state logic
    # Based on flip-flop type and state transition bits
    #
    # D flip-flop: D = next_state_bit (simple pass-through)
    # JK flip-flop: J and K inputs determine next state
    #   Q(t+1) = J*Q' + K'*Q
    # SR flip-flop: S and R inputs (one-hot: S=1/R=0 -> 1, R=1/S=0 -> 0)
    def self.generate_excitation_equations(fsm, flip_flop_type = :d)
      ff_type = flip_flop_type.to_sym
      raise FsmSynthesizer::ValidationError, "Unknown flip-flop type: #{ff_type}" unless FF_TYPES.key?(ff_type)

      case ff_type
      when :d
        generate_d_flip_flop_equations(fsm)
      when :jk
        generate_jk_flip_flop_equations(fsm)
      when :sr
        generate_sr_flip_flop_equations(fsm)
      end
    end

    private

    # D flip-flop: excitation = next state bit
    # D_i = d_i (where d_i is the next state bit i)
    def self.generate_d_flip_flop_equations(fsm)
      equations = {}

      fsm.state_bits.times do |bit_index|
        # D input is directly the next-state equation
        equations["D#{bit_index}"] = fsm.next_state_equations["D#{bit_index}"]
      end

      equations
    end

    # JK flip-flop: excitation depends on current and next state
    # Q(t+1) = J*Q'(t) + K'*Q(t)
    # For each transition:
    #   Q -> 0: J=0, K=1 (reset)
    #   0 -> 1: J=1, K=0 (set)
    #   Q -> Q: J=0, K=0 (hold) or J=1, K=1 (toggle->hold)
    #   1 -> 0: J=0, K=1 (reset)
    #   1 -> 1: J=1, K=0 (set) or J=0, K=0 (hold)
    def self.generate_jk_flip_flop_equations(fsm)
      j_equations = {}
      k_equations = {}

      fsm.state_bits.times do |bit_index|
        j_minterms = []
        k_minterms = []

        fsm.transitions.each do |transition|
          from_state = transition[:from]
          to_state = transition[:to]
          input_symbol = transition[:input]

          from_bits = fsm.state_encoding[from_state]
          to_bits = fsm.state_encoding[to_state]

          from_bit = from_bits[bit_index]
          to_bit = to_bits[bit_index]

          input_idx = fsm.inputs.index(input_symbol)
          if input_idx.nil?
            raise FsmSynthesizer::GenerationError,
                  "Unknown input symbol '#{input_symbol}' in JK flip-flop generation"
          end

          # Determine J and K based on state transition
          case "#{from_bit}#{to_bit}"
          when '00' # Stay 0: J=0, K=X (don't care)
            # J must be 0, K can be anything. We set K=0 (hold)
            # No J minterm needed
            # K minterm: NOT needed (K is don't care)
          when '01' # 0->1: J=1, K=X (don't care)
            j_minterms << { bits: from_bits, input_idx: }
            # K can be anything, we set K=0
          when '10' # 1->0: J=X (don't care), K=1
            k_minterms << { bits: from_bits, input_idx: }
            # J can be anything, we set J=0
          when '11' # Stay 1: J=X, K=0 (don't care for J)
            # J can be anything, we set J=1
            j_minterms << { bits: from_bits, input_idx: }
            # K must be 0, no K minterm needed
          end
        end

        # Generate SOP expressions
        j_equations["J#{bit_index}"] = generate_sop_expression(j_minterms, fsm.state_bits, fsm.inputs.size)
        k_equations["K#{bit_index}"] = generate_sop_expression(k_minterms, fsm.state_bits, fsm.inputs.size)
      end

      j_equations.merge(k_equations)
    end

    # SR flip-flop: Set and Reset inputs
    # S=1, R=0: Set to 1
    # S=0, R=1: Reset to 0
    # S=0, R=0: Hold current state
    # S=1, R=1: Invalid (not used)
    def self.generate_sr_flip_flop_equations(fsm)
      s_equations = {}
      r_equations = {}

      fsm.state_bits.times do |bit_index|
        s_minterms = []
        r_minterms = []

        fsm.transitions.each do |transition|
          from_state = transition[:from]
          to_state = transition[:to]
          input_symbol = transition[:input]

          from_bits = fsm.state_encoding[from_state]
          to_bits = fsm.state_encoding[to_state]

          from_bit = from_bits[bit_index]
          to_bit = to_bits[bit_index]

          input_idx = fsm.inputs.index(input_symbol)
          if input_idx.nil?
            raise FsmSynthesizer::GenerationError,
                  "Unknown input symbol '#{input_symbol}' in SR flip-flop generation"
          end

          # Determine S and R based on state transition
          case "#{from_bit}#{to_bit}"
          when '00' # Stay 0: S=0, R=0 (hold)
            # No S or R minterm needed
          when '01' # 0->1: S=1, R=0 (set)
            s_minterms << { bits: from_bits, input_idx: }
          when '10' # 1->0: S=0, R=1 (reset)
            r_minterms << { bits: from_bits, input_idx: }
          when '11' # Stay 1: S=0, R=0 (hold)
            # No S or R minterm needed
          end
        end

        # Generate SOP expressions
        s_equations["S#{bit_index}"] = generate_sop_expression(s_minterms, fsm.state_bits, fsm.inputs.size)
        r_equations["R#{bit_index}"] = generate_sop_expression(r_minterms, fsm.state_bits, fsm.inputs.size)
      end

      s_equations.merge(r_equations)
    end

    # Helper: Generate SOP expression from minterms
    def self.generate_sop_expression(minterms, state_bits, input_bits)
      return "0" if minterms.empty?

      terms = minterms.map do |minterm|
        state_part = minterm[:bits].map.with_index do |bit, idx|
          bit == 1 ? "Q#{idx}" : "~Q#{idx}"
        end.join(" & ")

        if state_part.empty?
          if minterm[:input_idx].nil?
            "1"
          else
            input_part = (0...input_bits).map do |idx|
              idx == minterm[:input_idx] ? "X#{idx}" : "~X#{idx}"
            end
            input_part.join(" & ")
          end
        else
          if minterm[:input_idx].nil?
            state_part
          else
            input_part = (0...input_bits).map do |idx|
              idx == minterm[:input_idx] ? "X#{idx}" : "~X#{idx}"
            end
            "#{state_part} & #{input_part.join(' & ')}"
          end
        end
      end

      terms.join(" | ")
    end

    private_class_method :generate_d_flip_flop_equations,
                         :generate_jk_flip_flop_equations,
                         :generate_sr_flip_flop_equations,
                         :generate_sop_expression
  end
end
