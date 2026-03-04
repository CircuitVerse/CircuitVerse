module FsmSynthesizer
  # InputSynchronizer: Generates clock domain crossing (CDC) synchronizers for FSM inputs
  #
  # Purpose:
  #   When FSM inputs come from different clock domains, direct connection causes metastability
  #   This service generates proper synchronizers to safely cross clock domains
  #
  # Synchronizer Types:
  #   1. Two-flop synchronizer - Standard for single-bit signals
  #   2. Gray code synchronizer - Multi-bit bus crossing
  #   3. Pulse synchronizer - Detect and propagate pulses
  #   4. Handshake synchronizer - Async FIFO-based data transfer
  #
  # Example:
  #   synchronizer = FsmSynthesizer::InputSynchronizer.new
  #   sync_config = synchronizer.configure_synchronizer(
  #     fsm,
  #     input_name: 'external_input',
  #     src_clock: 'clk_src',
  #     dest_clock: 'clk_sys'
  #   )
  #   sync_equations = synchronizer.generate_sync_equations(fsm, sync_config)

  class InputSynchronizer
    attr_accessor :fsm
    attr_accessor :synchronizers

    def initialize
      @synchronizers = {}
    end

    # Configure a single input synchronizer
    #
    # Parameters:
    #   fsm - FSM object
    #   config - Hash with keys:
    #     :input_name (String) - Name of FSM input
    #     :src_clock (String) - Source clock domain (where input originates)
    #     :dest_clock (String) - Destination clock domain (FSM clock)
    #     :sync_type (String) - Type: "two_flop", "gray", "pulse", "handshake"
    #     :num_stages (Integer) - Number of synchronization stages (default: 2)
    #
    # Returns:
    #   Configured synchronizer specification hash
    #
    # Raises:
    #   FsmSynthesizer::ValidationError - If input not found in FSM
    def configure_synchronizer(fsm, input_name:, src_clock:, dest_clock:, 
                               sync_type: 'two_flop', num_stages: 2)
      @fsm = fsm

      # Validate input exists
      unless @fsm.inputs.include?(input_name)
        raise FsmSynthesizer::ValidationError, 
              "Input '#{input_name}' not found in FSM. Available: #{@fsm.inputs.join(', ')}"
      end

      # Validate synchronizer type
      valid_types = ['two_flop', 'gray', 'pulse', 'handshake']
      unless valid_types.include?(sync_type)
        raise FsmSynthesizer::ValidationError,
              "Invalid sync type '#{sync_type}'. Must be: #{valid_types.join(', ')}"
      end

      # Validate num_stages
      unless num_stages.is_a?(Integer) && num_stages >= 2
        raise FsmSynthesizer::ValidationError, 'num_stages must be integer >= 2'
      end

      config = {
        input_name: input_name,
        src_clock: src_clock,
        dest_clock: dest_clock,
        sync_type: sync_type,
        num_stages: num_stages,
        metastability_msat: calculate_metastability_margin(num_stages, sync_type),
        settling_time_ns: calculate_settling_time(num_stages, sync_type)
      }

      @synchronizers[input_name] = config
      config
    end

    # Configure multiple input synchronizers at once
    #
    # Parameters:
    #   fsm - FSM object
    #   configs - Array of configuration hashes (each with keys as in configure_synchronizer)
    #
    # Returns:
    #   Hash of { input_name => configured_spec, ... }
    def configure_synchronizers(fsm, configs)
      @fsm = fsm
      configs.each do |config|
        configure_synchronizer(
          fsm,
          input_name: config[:input_name],
          src_clock: config[:src_clock],
          dest_clock: config[:dest_clock],
          sync_type: config.fetch(:sync_type, 'two_flop'),
          num_stages: config.fetch(:num_stages, 2)
        )
      end
      @synchronizers
    end

    # Generate synchronized input equations
    # Incorporates synchronizer flip-flops into input equations
    #
    # Parameters:
    #   fsm - FSM object with synchronizers configured
    #   input_equations - Hash of input equations from state machine
    #
    # Returns:
    #   Modified equations referencing synchronized inputs
    def generate_sync_equations(fsm, input_equations)
      @fsm = fsm
      synchronized_equations = {}

      input_equations.each do |equation_id, equation_expr|
        # Check if this input has a synchronizer configured
        input_name = extract_input_name(equation_id)
        
        if @synchronizers[input_name]
          config = @synchronizers[input_name]
          
          # Replace input with synchronized version
          # Input 'X' becomes 'X_sync' (output of synchronizer)
          synchronized_expr = equation_expr.gsub(
            /\b#{Regexp.escape(input_name)}\b/,
            "#{input_name}_sync"
          )
          synchronized_equations[equation_id] = synchronized_expr
        else
          # No synchronizer for this input, keep original
          synchronized_equations[equation_id] = equation_expr
        end
      end

      synchronized_equations
    end

    # Get synchronizer circuit specifications
    #
    # Returns:
    #   Hash with circuit structure for all configured synchronizers
    def get_synchronizer_circuits
      circuits = {}

      @synchronizers.each do |input_name, config|
        circuits[input_name] = generate_synchronizer_circuit(config)
      end

      circuits
    end

    # Get synchronizer for specific input
    #
    # Returns:
    #   Synchronizer configuration or nil if not found
    def get_synchronizer(input_name)
      @synchronizers[input_name]
    end

    # Calculate metastability margin (MSAT)
    # Higher values indicate better timing margin
    # MSAT > 3 is generally acceptable
    #
    # Formula:
    #   MSAT = (Tco - Tsu) / ln(2) / (2 * num_stages)
    #   Where Tco = flip-flop clock-to-Q delay
    #         Tsu = flip-flop setup time
    #   Typical ratio (Tco - Tsu) ≈ 3ns
    private

    def calculate_metastability_margin(num_stages, sync_type)
      # Typical flip-flop parameters (in ns)
      max_delay = 3.0  # Max of (Tco - Tsu)
      
      case sync_type
      when 'two_flop'
        # Standard 2-stage synchronizer
        margin = (max_delay / Math.log(2)) / (2.0 * num_stages)
      when 'gray'
        # Gray code improves margin slightly
        margin = (max_delay / Math.log(2)) / (1.5 * num_stages)
      when 'pulse'
        # Pulse synchronizer has similar margin
        margin = (max_delay / Math.log(2)) / (2.0 * num_stages)
      when 'handshake'
        # Handshake has extra settling time
        margin = (max_delay / Math.log(2)) / (1.2 * num_stages)
      else
        0.0
      end

      margin.round(2)
    end

    def calculate_settling_time(num_stages, sync_type)
      # Typical flip-flop delay (in ns)
      stage_delay = 1.5  # Tco of flip-flop
      
      case sync_type
      when 'two_flop'
        # Simple series chain
        settling = num_stages * stage_delay * 2  # 2x for margin
      when 'gray'
        # Gray code decoder adds delay
        settling = (num_stages * stage_delay) + 2.0
      when 'pulse'
        # Pulse detection adds delay
        settling = (num_stages * stage_delay) + 1.0
      when 'handshake'
        # Async FIFO adds significant delay
        settling = (num_stages * stage_delay * 3) + 5.0
      else
        0.0
      end

      settling.round(2)
    end

    def extract_input_name(equation_id)
      # Input equations usually formatted as "input_name" or similar
      # Return the input name from equation_id
      equation_id.to_s
    end

    def generate_synchronizer_circuit(config)
      case config[:sync_type]
      when 'two_flop'
        generate_two_flop_circuit(config)
      when 'gray'
        generate_gray_sync_circuit(config)
      when 'pulse'
        generate_pulse_circuit(config)
      when 'handshake'
        generate_handshake_circuit(config)
      else
        {}
      end
    end

    def generate_two_flop_circuit(config)
      {
        type: 'two_flop_synchronizer',
        description: 'Standard 2-stage (or N-stage) synchronizer for single-bit CDC',
        input: {
          name: config[:input_name],
          clock: config[:src_clock],
          domain: 'source_domain'
        },
        output: {
          name: "#{config[:input_name]}_sync",
          clock: config[:dest_clock],
          domain: 'destination_domain'
        },
        components: [
          {
            type: 'flip_flop_chain',
            description: "#{config[:num_stages]}-stage synchronizer chain",
            stages: config[:num_stages],
            flip_flops: (1..config[:num_stages]).map do |i|
              {
                name: "SYNC#{i}",
                clock: config[:dest_clock],
                input: i == 1 ? config[:input_name] : "SYNC#{i-1}",
                output: "SYNC#{i}"
              }
            end
          }
        ],
        timing: {
          metastability_margin_sigma: config[:metastability_msat],
          settling_time_ns: config[:settling_time_ns],
          max_freq_mhz: calculate_max_frequency(config[:settling_time_ns])
        },
        reliability: {
          mtbf_years: calculate_mtbf(config[:metastability_msat]),
          hazard_probability: calculate_hazard_probability(config[:num_stages])
        }
      }
    end

    def generate_gray_sync_circuit(config)
      {
        type: 'gray_code_synchronizer',
        description: 'Gray code synchronizer for multi-bit bus CDC',
        input: {
          name: config[:input_name],
          width: 'variable',
          clock: config[:src_clock],
          domain: 'source_domain'
        },
        output: {
          name: "#{config[:input_name]}_sync",
          width: 'variable',
          clock: config[:dest_clock],
          domain: 'destination_domain'
        },
        components: [
          {
            type: 'gray_encoder',
            description: 'Convert input to Gray code',
            input: config[:input_name],
            output: "#{config[:input_name]}_gray"
          },
          {
            type: 'synchronizer_chain',
            description: "#{config[:num_stages]}-stage synchronizer on Gray code",
            stages: config[:num_stages],
            input: "#{config[:input_name]}_gray",
            output: "#{config[:input_name]}_gray_sync"
          },
          {
            type: 'gray_decoder',
            description: 'Decode synchronized Gray code back to binary',
            input: "#{config[:input_name]}_gray_sync",
            output: "#{config[:input_name]}_sync"
          }
        ],
        timing: {
          metastability_margin_sigma: config[:metastability_msat],
          settling_time_ns: config[:settling_time_ns],
          max_freq_mhz: calculate_max_frequency(config[:settling_time_ns])
        }
      }
    end

    def generate_pulse_circuit(config)
      {
        type: 'pulse_synchronizer',
        description: 'Synchronizer for pulse/strobe signals (detects transitions)',
        input: {
          name: config[:input_name],
          clock: config[:src_clock],
          domain: 'source_domain',
          signal_type: 'pulse'
        },
        output: {
          name: "#{config[:input_name]}_pulse",
          clock: config[:dest_clock],
          domain: 'destination_domain'
        },
        components: [
          {
            type: 'pulse_detector',
            description: 'Detect rising edge in source domain',
            input: config[:input_name],
            output: "#{config[:input_name]}_detect"
          },
          {
            type: 'toggle_logic',
            description: 'Convert pulse to toggle signal',
            input: "#{config[:input_name]}_detect",
            output: "#{config[:input_name]}_toggle"
          },
          {
            type: 'synchronizer_chain',
            description: 'Synchronize toggle signal',
            stages: config[:num_stages],
            input: "#{config[:input_name]}_toggle",
            output: "#{config[:input_name]}_toggle_sync"
          },
          {
            type: 'edge_detector',
            description: 'Re-detect edges in destination domain',
            input: "#{config[:input_name]}_toggle_sync",
            output: "#{config[:input_name]}_pulse"
          }
        ],
        timing: {
          metastability_margin_sigma: config[:metastability_msat],
          detection_latency_ns: config[:settling_time_ns] + 2.0
        }
      }
    end

    def generate_handshake_circuit(config)
      {
        type: 'handshake_fifo',
        description: 'Async FIFO with CDC-safe handshake control',
        input: {
          name: config[:input_name],
          clock: config[:src_clock],
          domain: 'source_domain'
        },
        output: {
          name: "#{config[:input_name]}_data",
          clock: config[:dest_clock],
          domain: 'destination_domain'
        },
        components: [
          {
            type: 'write_logic',
            domain: 'source_domain',
            signals: [
              { name: 'write_ptr', width: 'address_width' },
              { name: 'write_en', width: 1 },
              { name: 'read_ptr_sync', description: 'Synced from dest domain' }
            ]
          },
          {
            type: 'fifo_memory',
            description: 'Dual-clock FIFO array',
            size: 'configurable',
            read_domain: config[:dest_clock],
            write_domain: config[:src_clock]
          },
          {
            type: 'pointers_sync',
            description: 'Synchronize read/write pointers across domains',
            components: [
              {
                name: 'write_ptr_to_read_sync',
                destination: 'destination_domain',
                stages: config[:num_stages]
              },
              {
                name: 'read_ptr_to_write_sync',
                destination: 'source_domain',
                stages: config[:num_stages]
              }
            ]
          },
          {
            type: 'read_logic',
            domain: 'destination_domain',
            signals: [
              { name: 'read_ptr', width: 'address_width' },
              { name: 'read_en', width: 1 },
              { name: 'write_ptr_sync', description: 'Synced from src domain' }
            ]
          }
        ],
        timing: {
          metastability_margin_sigma: config[:metastability_msat],
          settling_time_ns: config[:settling_time_ns],
          throughput_bytes_per_cycle: config[:num_stages]
        }
      }
    end

    def calculate_max_frequency(settling_time_ns)
      # Max frequency based on settling time
      # Assuming 10ns clock minimum for settling + clock margin
      min_period_ns = settling_time_ns + 2.0
      max_freq = (1000.0 / min_period_ns).round(0)
      max_freq > 0 ? max_freq : 1
    end

    def calculate_mtbf(metastability_margin)
      # MTBF (Mean Time Between Failures) calculation
      # Exponential: MTBF ∝ exp(metastability_margin)
      # This is simplified; real calculation requires many parameters
      
      if metastability_margin < 2.0
        mtbf_years = 0.1
      elsif metastability_margin < 3.0
        mtbf_years = 1.0
      elsif metastability_margin < 4.0
        mtbf_years = 10.0
      else
        mtbf_years = 100.0
      end
      
      mtbf_years
    end

    def calculate_hazard_probability(num_stages)
      # Probability of metastability not resolving
      # Decreases exponentially with number of stages
      base_prob = 1e-6  # Base hazard per stage
      (base_prob / (2.0 ** (num_stages - 1))).round(10)
    end
  end
end
