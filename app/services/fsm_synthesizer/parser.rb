# frozen_string_literal: true

module FsmSynthesizer
  class Parser
    # Parse FSM definition from JSON string
    # Returns: FsmSynthesizer::Base instance (fully validated)
    # Raises: FsmSynthesizer::ValidationError if invalid
    def self.parse_json(json_string)
      parsed = JSON.parse(json_string)
      parse_hash(parsed)
    rescue JSON::ParserError => e
      raise FsmSynthesizer::ValidationError, "Invalid JSON: #{e.message}"
    end

    # Parse FSM definition from hash
    # Accepts: { machine_type, inputs, outputs, states, transitions, state_outputs }
    # Note: Performs structural validation only. For determinism and completeness
    # checks, call FsmSynthesizer::Validator.validate(fsm) after parsing.
    def self.parse_hash(data)
      validate_required_keys(data)

      machine_type = data['machine_type']&.to_sym || data[:machine_type]
      inputs = Array(data['inputs'] || data[:inputs])
      outputs = Array(data['outputs'] || data[:outputs])
      states = normalize_states(data['states'] || data[:states])
      transitions = normalize_transitions(data['transitions'] || data[:transitions])
      state_outputs = normalize_state_outputs(data['state_outputs'] || data[:state_outputs])

      # Create FSM instance
      fsm = FsmSynthesizer::Base.new(
        machine_type:,
        inputs:,
        outputs:,
        states:,
        transitions:,
        state_outputs:
      )

      # Validate before returning
      fsm.validate
      fsm
    rescue FsmSynthesizer::ValidationError => e
      raise
    rescue StandardError => e
      raise FsmSynthesizer::ValidationError, "Error parsing FSM: #{e.message}"
    end

    # Parse FSM from CSV/table format
    # Format:
    #   machine_type: moore
    #   inputs: X,Y
    #   outputs: Z
    #   states: S0(initial),S1,S2
    #   transitions:
    #   from,input,to,output
    #   S0,0,S1,z
    #   S0,1,S2,z
    def self.parse_csv(csv_string)
      lines = csv_string.strip.split("\n").map(&:strip).reject(&:empty?)

      data = {
        'machine_type' => nil,
        'inputs' => [],
        'outputs' => [],
        'states' => [],
        'transitions' => [],
        'state_outputs' => {}
      }

      current_section = nil
      transition_headers = nil

      lines.each do |line|
        # Skip comments
        next if line.start_with?('#')

        # Section headers
        if line.downcase.start_with?('machine_type:')
          data['machine_type'] = line.split(':', 2)[1].strip.downcase
          next
        elsif line.downcase.start_with?('inputs:')
          data['inputs'] = parse_csv_list(line.split(':', 2)[1])
          next
        elsif line.downcase.start_with?('outputs:')
          data['outputs'] = parse_csv_list(line.split(':', 2)[1])
          next
        elsif line.downcase.start_with?('states:')
          data['states'] = parse_csv_list(line.split(':', 2)[1])
          next
        elsif line.downcase.start_with?('state_outputs:') || line.downcase.start_with?('moore_outputs:')
          current_section = 'state_outputs'
          next
        elsif line.downcase.start_with?('transitions:')
          current_section = 'transitions'
          next
        end

        # Transitions section: first line is header
        if current_section == 'transitions'
          if transition_headers.nil?
            transition_headers = line.split(',').map(&:strip)
          else
            data['transitions'] << parse_transition_line(line, transition_headers)
          end
        elsif current_section == 'state_outputs'
          # Format: state,output
          parts = line.split(',').map(&:strip)
          data['state_outputs'][parts[0]] = parts[1] if parts.size == 2
        end
      end

      # Convert states format if needed
      if data['states'].is_a?(Array) && data['states'].first&.include?('(initial)')
        data['states'] = data['states'].map do |state_str|
          if state_str.include?('(initial)')
            { id: state_str.sub('(initial)', '').strip, initial: true }
          else
            { id: state_str, initial: false }
          end
        end
      else
        states_array = Array(data['states']).map { |s| { id: s, initial: false } }
        data['states'] = states_array
        # Guard against empty array before accessing first element
        data['states'][0][:initial] = true if data['states'].any?
      end

      parse_hash(data)
    rescue FsmSynthesizer::ValidationError => e
      raise
    rescue StandardError => e
      raise FsmSynthesizer::ValidationError, "Error parsing CSV: #{e.message}"
    end

    private

    def self.validate_required_keys(data)
      required = ['machine_type', 'inputs', 'outputs', 'states', 'transitions']
      missing = required.select do |key|
        # Check both string and symbol keys
        value = data[key] || data[key.to_sym]
        value.nil? || (value.respond_to?(:empty?) && value.empty?)
      end

      if missing.any?
        raise FsmSynthesizer::ValidationError, "Missing required fields: #{missing.join(', ')}"
      end
    end

    def self.normalize_states(states_data)
      return [] if states_data.nil?

      Array(states_data).map do |state|
        case state
        when Hash
          { id: state['id'] || state[:id], initial: state['initial'] || state[:initial] || false }
        when String
          { id: state, initial: false }
        else
          raise FsmSynthesizer::ValidationError, "Invalid state format: #{state.inspect}"
        end
      end
    end

    def self.normalize_transitions(transitions_data)
      return [] if transitions_data.nil?

      Array(transitions_data).map do |transition|
        case transition
        when Hash
          {
            from: transition['from'] || transition[:from],
            input: transition['input'] || transition[:input],
            to: transition['to'] || transition[:to],
            output: transition['output'] || transition[:output]
          }
        when Array
          { from: transition[0], input: transition[1], to: transition[2], output: transition[3] }
        else
          raise FsmSynthesizer::ValidationError, "Invalid transition format: #{transition.inspect}"
        end
      end
    end

    def self.normalize_state_outputs(state_outputs_data)
      return {} if state_outputs_data.nil?

      case state_outputs_data
      when Hash
        state_outputs_data.transform_keys(&:to_s)
      when Array
        state_outputs_data.each_with_object({}) do |pair, hash|
          # Validate pair format and normalize keys to strings
          unless pair.is_a?(Array) && pair.size == 2
            raise FsmSynthesizer::ValidationError, "Invalid state_outputs pair format: #{pair.inspect}"
          end
          key, value = pair
          hash[key.to_s] = value
        end
      else
        {}
      end
    end

    def self.parse_csv_list(csv_string)
      csv_string&.split(',')&.map(&:strip)&.reject(&:empty?) || []
    end

    def self.parse_transition_line(line, headers)
      parts = line.split(',').map(&:strip)
      transition = {}

      headers.each_with_index do |header, idx|
        transition[header.downcase.to_sym] = parts[idx]
      end

      transition
    end
  end
end
