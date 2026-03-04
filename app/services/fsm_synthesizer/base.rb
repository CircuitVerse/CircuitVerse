# frozen_string_literal: true

module FsmSynthesizer
  class Base
    # Machine type: :moore or :mealy
    attr_accessor :machine_type

    # Input and output alphabets
    attr_accessor :inputs  # Array of input symbols
    attr_accessor :outputs # Array of output symbols

    # State definitions
    # Each state is a hash: { id: 'S0', initial: true }
    attr_accessor :states

    # Transitions
    # Each transition is a hash: { from: 'S0', input: '0', to: 'S1', output: 'y' }
    attr_accessor :transitions

    # For Moore machines: state -> output mapping
    # { 'S0' => 'z0', 'S1' => 'z1', ... }
    attr_accessor :state_outputs

    # Generated outputs after synthesis
    attr_accessor :state_encoding      # { 'S0' => [0, 0], 'S1' => [0, 1], ... }
    attr_accessor :next_state_equations # { 'D0' => '~Q0 & Q1 & ~X', ... }
    attr_accessor :output_equations    # { 'y' => '~Q0 & Q1', ... }
    attr_accessor :state_bits          # Number of flip-flops needed

    def initialize(machine_type:, inputs:, outputs:, states:, transitions:, state_outputs: nil)
      @machine_type = machine_type
      @inputs = inputs
      @outputs = outputs
      @states = states
      @transitions = transitions
      @state_outputs = state_outputs || {}
    end

    # Validate FSM structure
    def validate
      errors = []
      errors.concat(validate_machine_type)
      errors.concat(validate_states)
      errors.concat(validate_inputs_outputs)
      errors.concat(validate_transitions)
      errors.concat(validate_machine_specific)

      raise FsmSynthesizer::ValidationError, errors.join("; ") unless errors.empty?

      true
    end

    private

    def validate_machine_type
      return [] if %i[moore mealy].include?(@machine_type)

      ["Machine type must be :moore or :mealy, got #{@machine_type.inspect}"]
    end

    def validate_states
      errors = []
      errors << "States must be provided" if @states.nil? || @states.empty?
      return errors if @states.nil? || @states.empty?

      # Validate state IDs for presence and uniqueness
      state_ids = []
      @states.each_with_index do |state, idx|
        errors << "State at index #{idx} is missing :id field" unless state.is_a?(Hash) && state[:id].present?
        if state.is_a?(Hash) && state[:id].present?
          if state_ids.include?(state[:id])
            errors << "Duplicate state ID: #{state[:id]}"
          else
            state_ids << state[:id]
          end
        end
      end

      initial_states = @states.select { |s| s[:initial] == true }
      if initial_states.empty?
        errors << "Exactly one initial state is required"
      elsif initial_states.size > 1
        errors << "Only one initial state is allowed"
      end

      errors
    end

    def validate_inputs_outputs
      errors = []
      errors << "Inputs must be provided" if @inputs.nil? || @inputs.empty?
      errors << "Outputs must be provided" if @outputs.nil? || @outputs.empty?
      errors
    end

    def validate_transitions
      errors = []
      if @transitions.nil? || @transitions.empty?
        errors << "Transitions must be provided"
        return errors
      end
      return errors if @states.nil? || @states.empty? || @inputs.nil? || @inputs.empty?

      state_ids = @states.map { |s| s[:id] }.to_set

      @transitions.each do |transition|
        errors << "Transition missing 'from' state" unless transition[:from]
        errors << "Transition missing 'input'" unless transition[:input]
        errors << "Transition missing 'to' state" unless transition[:to]

        errors << "Unknown 'from' state: #{transition[:from]}" unless state_ids.include?(transition[:from])
        errors << "Unknown 'to' state: #{transition[:to]}" unless state_ids.include?(transition[:to])
        errors << "Unknown input symbol: #{transition[:input]}" unless @inputs.include?(transition[:input])

        if @machine_type == :mealy && !transition[:output]
          errors << "Mealy transition missing 'output': #{transition}"
        end

        if transition[:output] && !@outputs.include?(transition[:output])
          errors << "Unknown output symbol: #{transition[:output]}"
        end
      end

      errors
    end

    def validate_machine_specific
      errors = []

      if @machine_type == :moore
        # Guard against nil states and outputs to avoid NoMethodError
        return errors if @states.nil? || @outputs.nil?
        return errors unless @state_outputs.is_a?(Hash)

        state_ids = @states.map { |s| s[:id] }
        missing = state_ids - @state_outputs.keys
        errors << "Missing state_outputs for states: #{missing.join(', ')}" unless missing.empty?

        @state_outputs.each do |state_id, output|
          errors << "Unknown state in state_outputs: #{state_id}" unless @states.any? { |s| s[:id] == state_id }
          errors << "Unknown output in state_outputs: #{output}" unless @outputs.include?(output)
        end
      end

      errors
    end
  end
end
