# frozen_string_literal: true

module FsmSynthesizer
  # Gray Code (Reflected Binary Code) encoder for state assignment
  # Properties:
  # - Adjacent values differ by exactly one bit
  # - Minimizes state transition hazards
  # - Often produces simpler next-state logic
  # - Reduces glitches in combinational circuits
  class GrayCodeEncoder
    # Convert decimal number to Gray code representation as bit array
    #
    # Gray code formula: Gray(n) = n XOR (n >> 1)
    # Example: 5 = 0101 -> 0111 (7 in decimal, which is Gray representation)
    #
    # @param number [Integer] Decimal number to convert (0-indexed state)
    # @param num_bits [Integer] Number of bits for representation
    # @return [Array<Integer>] Gray code as array of bits [0..n]
    def self.to_gray_code(number, num_bits)
      raise FsmSynthesizer::EncodingError, "number must be non-negative" if number.negative?
      raise FsmSynthesizer::EncodingError, "num_bits must be positive" if num_bits <= 0
      raise FsmSynthesizer::EncodingError, "number #{number} too large for #{num_bits} bits" if number >= (1 << num_bits)

      # Compute Gray code: gray = number XOR (number >> 1)
      gray = number ^ (number >> 1)

      # Convert to bit array
      bits = []
      num_bits.times do |i|
        bit = (gray >> (num_bits - 1 - i)) & 1
        bits << bit
      end

      bits
    end

    # Verify that two bit arrays (Gray codes) differ by exactly one bit
    # This validates the Gray code property
    #
    # @param bits1 [Array<Integer>] First bit array
    # @param bits2 [Array<Integer>] Second bit array
    # @return [Boolean] true if arrays differ by exactly one bit
    def self.differ_by_one_bit?(bits1, bits2)
      return false unless bits1.size == bits2.size

      differences = 0
      bits1.each_with_index do |bit, idx|
        differences += 1 if bit != bits2[idx]
      end

      differences == 1
    end

    # Generate comparison metric between encoding types
    # Counts number of state transitions that require more than one bit change
    #
    # Used to evaluate encoding quality:
    # - Lower count = fewer hazards and glitches
    # - Fewer multi-bit transitions = simpler next-state equations
    #
    # @param fsm [FsmSynthesizer::Base] FSM with populated state_encoding
    # @return [Integer] Count of multi-bit transitions
    def self.count_multibitechanges(fsm)
      multibits = 0

      # Check each transition
      fsm.transitions.each do |transition|
        from_state = transition[:from]
        to_state = transition[:to]

        from_bits = fsm.state_encoding[from_state]
        to_bits = fsm.state_encoding[to_state]

        next if from_bits.nil? || to_bits.nil?

        # Count bit differences
        bit_changes = 0
        from_bits.each_with_index do |bit, idx|
          bit_changes += 1 if bit != to_bits[idx]
        end

        multibits += 1 if bit_changes > 1
      end

      multibits
    end

    # Encode FSM using Gray code for all states
    #
    # Gray code assignment:
    # - States 0..N-1 -> Gray codes ensuring adjacent codes differ by 1 bit
    # - Reduces critical path in combinational logic
    # - Decreases probability of timing hazards
    # - Simplifies output equations for state-dependent behavior
    #
    # @param fsm [FsmSynthesizer::Base] FSM to encode
    # @return [void] Modifies fsm.state_encoding in-place
    def self.encode(fsm)
      unless fsm.state_bits
        raise FsmSynthesizer::EncodingError, "state_bits not calculated. Call FSM validation first."
      end

      fsm.state_encoding = {}

      fsm.states.each_with_index do |state, index|
        state_id = state[:id]
        gray_bits = to_gray_code(index, fsm.state_bits)
        fsm.state_encoding[state_id] = gray_bits
      end
    end

    # Compare encoding strategies and return recommendation
    # Evaluates binary, one-hot, and Gray code encodings
    #
    # @param fsm [FsmSynthesizer::Base] FSM with populated encoding
    # @param comparison_fsm_binary [FsmSynthesizer::Base] Copy with binary encoding
    # @param comparison_fsm_onehot [FsmSynthesizer::Base] Copy with one-hot encoding
    # @return [Hash] Comparison metrics and recommendations
    def self.compare_encodings(fsm, comparison_fsm_binary = nil, comparison_fsm_onehot = nil)
      # Calculate multi-bit changes for Gray code (current FSM)
      gray_multibits = count_multibitechanges(fsm)

      # Calculate for binary if not provided
      binary_multibits = if comparison_fsm_binary
                           count_multibitechanges(comparison_fsm_binary)
                         else
                           calculate_binary_multibits(fsm)
                         end

      # Calculate for one-hot if not provided
      onehot_multibits = if comparison_fsm_onehot
                           count_multibitechanges(comparison_fsm_onehot)
                         else
                           calculate_onehot_multibits(fsm)
                         end

      {
        gray_code: gray_multibits,
        binary: binary_multibits,
        one_hot: onehot_multibits,
        best_encoding: determine_best_encoding(gray_multibits, binary_multibits, onehot_multibits),
        recommendation: recommend_encoding(fsm.states.size)
      }
    end

    private

    # Estimate multi-bit transitions for binary encoding
    def self.calculate_binary_multibits(fsm)
      multibits = 0
      num_bits = fsm.state_bits

      fsm.transitions.each do |transition|
        from_idx = fsm.states.find_index { |s| s[:id] == transition[:from] }
        to_idx = fsm.states.find_index { |s| s[:id] == transition[:to] }

        next if from_idx.nil? || to_idx.nil?

        # Count bit differences in binary representation
        bit_changes = 0
        num_bits.times do |i|
          from_bit = (from_idx >> (num_bits - 1 - i)) & 1
          to_bit = (to_idx >> (num_bits - 1 - i)) & 1
          bit_changes += 1 if from_bit != to_bit
        end

        multibits += 1 if bit_changes > 1
      end

      multibits
    end

    # Estimate multi-bit transitions for one-hot encoding
    def self.calculate_onehot_multibits(fsm)
      # One-hot always has multi-bit transitions (except self-loops)
      # Each transition from state i to state j requires turning off bit i and turning on bit j
      multibits = 0

      fsm.transitions.each do |transition|
        from_state = transition[:from]
        to_state = transition[:to]

        multibits += 1 unless from_state == to_state
      end

      multibits
    end

    # Determine best encoding based on multi-bit change count
    def self.determine_best_encoding(gray, binary, onehot)
      encodings = { gray_code: gray, binary: binary, one_hot: onehot }
      best = encodings.min_by { |_type, count| count }
      best[0].to_s
    end

    # Recommend encoding based on FSM size
    # Gray code is most beneficial when:
    # - 4-32 states (enough for multiple bits, few enough for Gray to help)
    # - Many state transitions (hazard reduction matters)
    # One-hot is better for very few states
    # Binary is more compact for many states
    def self.recommend_encoding(num_states)
      case num_states
      when 2
        "one_hot (minimal states)"
      when 3..4
        "gray_code (reduces hazards)"
      when 5..32
        "gray_code (best balance of logic and hazards)"
      else
        "binary (many states, smaller logic)"
      end
    end
  end
end
