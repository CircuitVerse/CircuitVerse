# frozen_string_literal: true

module FsmSynthesizer
  # FSM Reset Configuration and Reset Circuit Generation
  # Supports synchronous and asynchronous reset strategies
  class ResetController
    # Reset type enumeration
    RESET_TYPES = {
      none: 'No reset',
      synchronous: 'Synchronous reset (on clock)',
      asynchronous: 'Asynchronous reset (immediate)'
    }.freeze

    # Default reset state is the initial state
    # Can be overridden via configuration
    def self.configure_reset(fsm, reset_type = :synchronous, reset_state = nil)
      reset_type = reset_type.to_sym
      raise FsmSynthesizer::ValidationError, "Unknown reset type: #{reset_type}" unless RESET_TYPES.key?(reset_type)

      # Determine reset state (default to initial state if not specified)
      target_state = if reset_state.nil?
                       fsm.states.find { |s| s[:initial] }
                     else
                       fsm.states.find { |s| s[:id] == reset_state }
                     end

      raise FsmSynthesizer::ValidationError, "Reset state '#{reset_state}' not found" if target_state.nil?

      # Store reset configuration in FSM
      fsm.reset_type = reset_type
      fsm.reset_state = target_state[:id]

      { reset_type: reset_type, reset_state: target_state[:id] }
    end

    # Generate reset logic for encoding
    # Returns the bit pattern that represents the reset state
    #
    # Used by both synchronous and asynchronous implementations
    # @param fsm [FsmSynthesizer::Base] FSM with reset_state configured
    # @return [Array<Integer>] Bit pattern of reset state
    def self.get_reset_encoding(fsm)
      unless fsm.reset_state && fsm.state_encoding
        raise FsmSynthesizer::GenerationError, 'Reset state or state encoding not configured'
      end

      fsm.state_encoding[fsm.reset_state] || raise(
        FsmSynthesizer::GenerationError, "Reset state '#{fsm.reset_state}' encoding not found"
      )
    end

    # Generate asynchronous reset equations
    # Asynchronous reset: directly forces all state variable bits to reset values
    # Equation form: Q_i = ~RST OR next_state_i (when RST=0, forcing Q_i=0; when RST=1, Q_i follows next state)
    #
    # For reset states with non-zero bits, use: Q_i = ~RST then forced to 1, OR next_state_i
    #
    # @param fsm [FsmSynthesizer::Base] FSM with reset configuration and excitation equations
    # @param excitation_equations [Hash] Flip-flop excitation equations (D, J/K, or S/R)
    # @return [Hash] Reset-aware excitation equations
    def self.generate_async_reset_equations(fsm, excitation_equations)
      unless fsm.reset_state && fsm.state_encoding
        raise FsmSynthesizer::GenerationError, 'Reset configuration missing'
      end

      reset_bits = get_reset_encoding(fsm)
      reset_eqs = {}

      # For D flip-flops: D_i = (RST=0 forcing Q_i to reset value) OR (RST=1 AND normal equation)
      # Simplified: D_i = RST*D_i + ~RST*reset_bit_i
      excitation_equations.each do |eq_id, expr|
        match = eq_id.to_s.match(/\AD(\d+)\z/)
        next unless match

        bit_idx = match[1].to_i
        reset_bit = reset_bits[bit_idx]

        if reset_bit.zero?
          # Bit should be 0 in reset state: D_i = RST*expr
          reset_eqs[eq_id] = "RST & (#{expr})"
        else
          # Bit should be 1 in reset state: D_i = RST*expr + ~RST
          reset_eqs[eq_id] = "(RST & (#{expr})) | ~RST"
        end
      end

      # For JK and SR, generate modified equations
      # J/K equations need to handle reset forcing
      excitation_equations.each do |eq_id, expr|
        next if reset_eqs.key?(eq_id) # Already handled D flip-flops

        case eq_id.to_s[0]
        when 'J'
          # J modified: J = RST*J_expr (when RST=0, J=0 prevents setting)
          reset_eqs[eq_id] = "RST & (#{expr})"
        when 'K'
          # K modified: K = RST*K_expr OR ~RST (when RST=0, K=1 forces reset)
          bit_idx = eq_id.to_s.match(/K(\d+)\z/)[1].to_i
          reset_bit = reset_bits[bit_idx]
          reset_eqs[eq_id] = if reset_bit.zero?
                              "(RST & (#{expr})) | ~RST"
                            else
                              "RST & (#{expr})"
                            end
        when 'S'
          # S modified: S = RST*S_expr OR ~RST (when RST=0, S=0; when RST=1, S follows)
          bit_idx = eq_id.to_s.match(/S(\d+)\z/)[1].to_i
          reset_bit = reset_bits[bit_idx]
          if reset_bit.zero?
            # S should be 0 when reset: S = RST*expr
            reset_eqs[eq_id] = "RST & (#{expr})"
          else
            # S should be 1 when reset: S = (RST*expr) | ~RST
            reset_eqs[eq_id] = "(RST & (#{expr})) | ~RST"
          end
        when 'R'
          # R modified: R = RST*R_expr OR ~RST (when RST=0, R=1 forces reset)
          bit_idx = eq_id.to_s.match(/R(\d+)\z/)[1].to_i
          reset_bit = reset_bits[bit_idx]
          reset_eqs[eq_id] = if reset_bit.zero?
                              "(RST & (#{expr})) | ~RST"
                            else
                              "RST & (#{expr})"
                            end
        end
      end

      reset_eqs
    end

    # Generate synchronous reset equations
    # Synchronous reset: adds reset to the next-state logic DURING state transitions
    # Reset only takes effect on clock edge, same timing as normal state transitions
    #
    # @param fsm [FsmSynthesizer::Base] FSM with reset configuration
    # @param excitation_equations [Hash] Flip-flop excitation equations
    # @return [Hash] Reset-aware excitation equations
    def self.generate_sync_reset_equations(fsm, excitation_equations)
      unless fsm.reset_state && fsm.state_encoding
        raise FsmSynthesizer::GenerationError, 'Reset configuration missing'
      end

      reset_bits = get_reset_encoding(fsm)
      reset_eqs = {}

      # For synchronous reset, modify equations to include reset mux:
      # new_D_i = RST ? reset_bit_i : normal_D_i
      # Which translates to: D_i = (RST*reset_bit_i) + (~RST*normal_D_i)

      excitation_equations.each do |eq_id, expr|
        case eq_id.to_s[0]
        when 'D'
          bit_idx = eq_id.to_s.match(/D(\d+)\z/)[1].to_i
          reset_bit = reset_bits[bit_idx]

          # Mux: if RST then reset_bit else expr
          # D = (RST*reset_bit) + (~RST*normal_expr)
          reset_eqs[eq_id] = if reset_bit.zero?
                              "~RST & (#{expr})"
                            else
                              "(RST) | (~RST & (#{expr}))"
                            end
        when 'J'
          # For J: if RST then appropriate J value else normal J
          bit_idx = eq_id.to_s.match(/J(\d+)\z/)[1].to_i
          reset_bit = reset_bits[bit_idx]

          if reset_bit.zero?
            # Want to RESET (not set): J=0 when RST=1
            reset_eqs[eq_id] = "~RST & (#{expr})"
          else
            # Want to SET: J=1 when RST=1
            reset_eqs[eq_id] = "RST | (~RST & (#{expr}))"
          end
        when 'K'
          # For K: if RST then appropriate K value else normal K
          bit_idx = eq_id.to_s.match(/K(\d+)\z/)[1].to_i
          reset_bit = reset_bits[bit_idx]

          if reset_bit.zero?
            # Want to RESET: K=1 when RST=1
            reset_eqs[eq_id] = "RST | (~RST & (#{expr}))"
          else
            # Want to SET: K=0 when RST=1
            reset_eqs[eq_id] = "~RST & (#{expr})"
          end
        when 'S'
          # For S: if RST then appropriate S value else normal S
          bit_idx = eq_id.to_s.match(/S(\d+)\z/)[1].to_i
          reset_bit = reset_bits[bit_idx]

          if reset_bit.zero?
            # Want to RESET: S=0 when RST=1
            reset_eqs[eq_id] = "~RST & (#{expr})"
          else
            # Want to SET: S=1 when RST=1
            reset_eqs[eq_id] = "RST | (~RST & (#{expr}))"
          end
        when 'R'
          # For R: if RST then appropriate R value else normal R
          bit_idx = eq_id.to_s.match(/R(\d+)\z/)[1].to_i
          reset_bit = reset_bits[bit_idx]

          if reset_bit.zero?
            # Want to RESET: R=1 when RST=1
            reset_eqs[eq_id] = "RST | (~RST & (#{expr}))"
          else
            # Want to SET: R=0 when RST=1
            reset_eqs[eq_id] = "~RST & (#{expr})"
          end
        end
      end

      reset_eqs
    end

    # Generate reset circuit structure
    # Includes reset input, synchronization logic (if needed), and control signals
    #
    # @param fsm [FsmSynthesizer::Base] FSM with reset configuration
    # @return [Hash] Reset circuit metadata and components
    def self.generate_reset_circuit(fsm)
      unless fsm.reset_type && fsm.reset_type != :none
        raise FsmSynthesizer::GenerationError, 'Reset not configured'
      end

      reset_bits = get_reset_encoding(fsm)

      {
        reset_type: fsm.reset_type.to_s,
        reset_state: fsm.reset_state,
        reset_encoding: reset_bits,
        reset_input: {
          name: 'RST',
          polarity: 'active_low',
          description: 'Active-low reset signal'
        },
        reset_components: generate_reset_components(fsm, fsm.reset_type)
      }
    end

    private

    # Generate reset component specifications
    def self.generate_reset_components(fsm, reset_type)
      case reset_type
      when :asynchronous
        {
          type: 'async_reset_network',
          description: 'Direct reset to all flip-flops independent of clock',
          timing: 'immediate (propagation delay only)',
          components: [
            {
              id: 'RESET_BUFFER',
              type: 'buffer',
              description: 'Reset signal buffer for distribution'
            },
            {
              id: 'ASYNC_RESET_GATE',
              type: 'logic_gate_array',
              description: 'Asynchronous reset gates for each state bit'
            }
          ]
        }
      when :synchronous
        {
          type: 'sync_reset_network',
          description: 'Reset takes effect on next clock edge (same as state transitions)',
          timing: 'synchronized to clock',
          components: [
            {
              id: 'RESET_SYNC',
              type: 'synchronizer',
              description: 'CDC (clock domain crossing) synchronizer for reset'
            },
            {
              id: 'RESET_MUX',
              type: 'multiplexer_array',
              description: 'Multiplexers selecting reset value vs next state'
            }
          ]
        }
      else
        raise FsmSynthesizer::GenerationError, "Unknown reset type: #{reset_type}"
      end
    end
  end
end
