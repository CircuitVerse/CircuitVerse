module FsmSynthesizer
  # MetastabilityAnalyzer: Detects and analyzes CDC (Clock Domain Crossing) hazards
  #
  # Purpose:
  #   Identifies potential metastability issues when inputs cross clock domains
  #   Recommends appropriate synchronization strategies
  #   Generates detailed hazard reports
  #
  # Key Concepts:
  #   - Metastability: When a flip-flop input changes near clock edge
  #   - CDC Hazard: Potential for metastability with unprotected crossing
  #   - MSAT: Metastability margin (sigma = 3 is acceptable)
  #   - MTD: Mean Time to Disaster (related to MTBF)
  #
  # Example:
  #   analyzer = FsmSynthesizer::MetastabilityAnalyzer.new
  #   hazards = analyzer.analyze_crossing(fsm, 'ext_input', src_clock, dest_clock)
  #   report = analyzer.generate_report(fsm, synchronizers)

  class MetastabilityAnalyzer
    attr_accessor :hazards
    attr_accessor :recommendations

    def initialize
      @hazards = []
      @recommendations = []
    end

    # Analyze a single clock domain crossing for hazards
    #
    # Parameters:
    #   fsm - FSM object
    #   input_name - Name of input crossing domains
    #   src_clock - Source clock (where input comes from)
    #   dest_clock - Destination clock (FSM clock)
    #   freq_src_mhz - Source clock frequency (optional, default: 100)
    #   freq_dest_mhz - Destination clock frequency (optional, default: 100)
    #
    # Returns:
    #   Hash with hazard details
    def analyze_crossing(fsm, input_name, src_clock, dest_clock,
                        freq_src_mhz = 100, freq_dest_mhz = 100)
      raise FsmSynthesizer::ValidationError, 
            "Input '#{input_name}' not found" unless fsm.inputs.include?(input_name)

      hazard = {
        input_name: input_name,
        src_clock: src_clock,
        dest_clock: dest_clock,
        src_freq_mhz: freq_src_mhz,
        dest_freq_mhz: freq_dest_mhz,
        is_hazard: true,
        severity: calculate_hazard_severity(freq_src_mhz, freq_dest_mhz),
        risk_level: :high,
        synchronization_required: true,
        recommended_synchronizer: recommend_synchronizer(fsm, input_name),
        critical_factors: analyze_critical_factors(fsm, input_name),
        clock_frequency_ratio: (freq_src_mhz.to_f / freq_dest_mhz.to_f).round(2)
      }

      @hazards << hazard
      hazard
    end

    # Analyze multiple clock domain crossings
    #
    # Parameters:
    #   fsm - FSM object
    #   crossings - Array of crossing specs:
    #     { input_name, src_clock, dest_clock, freq_src_mhz, freq_dest_mhz }
    #
    # Returns:
    #   Array of hazard analyses
    def analyze_crossings(fsm, crossings)
      @hazards = []
      
      crossings.each do |crossing|
        analyze_crossing(
          fsm,
          crossing[:input_name],
          crossing[:src_clock],
          crossing[:dest_clock],
          crossing.fetch(:freq_src_mhz, 100),
          crossing.fetch(:freq_dest_mhz, 100)
        )
      end

      @hazards
    end

    # Check for metastability issues in a set of configured synchronizers
    #
    # Parameters:
    #   fsm - FSM object
    #   synchronizers - Hash of configured synchronizers from InputSynchronizer
    #
    # Returns:
    #   Hash with safety assessment
    def assess_synchronizer_safety(fsm, synchronizers)
      safety_assessment = {
        all_inputs_synchronized: synchronizers.keys.length == fsm.inputs.length,
        synchronized_inputs: synchronizers.keys,
        unsynchronized_inputs: fsm.inputs - synchronizers.keys,
        at_risk_inputs: [],
        overall_risk: :safe,
        safe_sync_count: 0,
        risky_sync_count: 0
      }

      synchronizers.each do |input_name, config|
        if config[:metastability_msat] < 2.0
          safety_assessment[:at_risk_inputs] << input_name
          safety_assessment[:risky_sync_count] += 1
        else
          safety_assessment[:safe_sync_count] += 1
        end
      end

      # Determine overall risk
      if safety_assessment[:unsynchronized_inputs].any?
        safety_assessment[:overall_risk] = :high
      elsif safety_assessment[:at_risk_inputs].any?
        safety_assessment[:overall_risk] = :medium
      else
        safety_assessment[:overall_risk] = :low
      end

      safety_assessment
    end

    # Generate comprehensive hazard report
    #
    # Returns:
    #   Detailed report hash with all analyzed crossings
    def generate_report(fsm, synchronizers = {})
      {
        timestamp: Time.now.iso8601,
        fsm_name: fsm.name || 'unnamed_fsm',
        inputs_count: fsm.inputs.length,
        total_crossings_analyzed: @hazards.length,
        hazards: @hazards,
        synchronizer_assessment: assess_synchronizer_safety(fsm, synchronizers),
        recommendations: generate_recommendations(synchronizers),
        summary: generate_summary
      }
    end

    # Get risk level for specific input
    #
    # Returns:
    #   Symbol: :critical, :high, :medium, :low, :none
    def get_risk_level(input_name)
      hazard = @hazards.find { |h| h[:input_name] == input_name }
      
      if hazard.nil?
        :none
      else
        hazard[:risk_level]
      end
    end

    # Check if synchronizer MSAT is acceptable
    #
    # Parameters:
    #   msat_value - Metastability margin sigma value
    #   acceptance_threshold - Minimum acceptable MSAT (default: 3)
    #
    # Returns:
    #   Boolean
    def is_msat_acceptable?(msat_value, acceptance_threshold = 3.0)
      msat_value >= acceptance_threshold
    end

    # Calculate MTBF (Mean Time Between Failures) category
    #
    # Parameters:
    #   msat_value - Metastability margin sigma
    #
    # Returns:
    #   String describing reliability
    def mtbf_category(msat_value)
      if msat_value < 1.0
        'Unacceptable (MTBF < 1 hour)'
      elsif msat_value < 2.0
        'Poor (MTBF ~1 day)'
      elsif msat_value < 3.0
        'Fair (MTBF ~1 week)'
      elsif msat_value < 4.0
        'Good (MTBF ~1 year)'
      else
        'Excellent (MTBF > 10 years)'
      end
    end

    # Private helper methods

    private

    def calculate_hazard_severity(freq_src, freq_dest)
      # Severity increases with frequency difference
      freq_ratio = (freq_src.to_f / freq_dest.to_f).abs
      
      if freq_ratio < 0.5 || freq_ratio > 2.0
        severity = 0.9
      elsif freq_ratio < 0.8 || freq_ratio > 1.25
        severity = 0.7
      else
        severity = 0.5
      end

      severity.round(2)
    end

    def recommend_synchronizer(fsm, input_name)
      # Recommendation logic based on FSM characteristics
      # For most cases, Gray code is better for multi-bit, two-flop for single-bit
      
      # Check if input is part of state encoding
      if fsm.states.include?(input_name)
        # Multi-bit signal
        { type: 'gray', num_stages: 2 }
      else
        # Single-bit signal
        { type: 'two_flop', num_stages: 2 }
      end
    end

    def analyze_critical_factors(fsm, input_name)
      factors = []
      
      # Check if input is used in timing-critical paths
      factors << :timing_critical if critical_in_state_machine?(fsm, input_name)
      
      # Check if input is high-frequency
      factors << :high_frequency if input_might_be_high_freq?(fsm, input_name)
      
      # Check if transitions depend on this input
      factors << :state_dependent if transitions_depend_on_input?(fsm, input_name)
      
      factors
    end

    def critical_in_state_machine?(fsm, input_name)
      # Check transitions - if many transitions depend on this input, it's critical
      count = fsm.transitions.count do |t|
        t[:condition].to_s.include?(input_name)
      end
      
      # If more than 50% of transitions use this input, it's timing-critical
      count > (fsm.transitions.length / 2)
    end

    def input_might_be_high_freq?(fsm, input_name)
      # Simple heuristic: short input names or '_clk' in name might be high frequency
      input_name.length < 3 || input_name.to_s.include?('_en')
    end

    def transitions_depend_on_input?(fsm, input_name)
      fsm.transitions.any? { |t| t[:condition].to_s.include?(input_name) }
    end

    def generate_recommendations(synchronizers)
      recommendations = []

      synchronizers.each do |input_name, config|
        recommendation = {
          input: input_name,
          synchronizer_type: config[:sync_type],
          num_stages: config[:num_stages],
          msat_margin: config[:metastability_msat]
        }

        # Recommend additional stages if MSAT is borderline
        if config[:metastability_msat] < 3.0
          recommendation[:improvement] = "Consider increasing num_stages from #{config[:num_stages]} to #{config[:num_stages] + 1}"
        elsif config[:num_stages] > 3
          recommendation[:improvement] = "Can reduce stages to 3 without sacrificing safety"
        else
          recommendation[:improvement] = 'Configuration is acceptable'
        end

        recommendations << recommendation
      end

      recommendations
    end

    def generate_summary
      if @hazards.empty?
        'No clock domain crossings analyzed'
      else
        critical = @hazards.count { |h| h[:risk_level] == :critical }
        high = @hazards.count { |h| h[:risk_level] == :high }
        
        if critical > 0
          "CRITICAL: #{critical} inputs need immediate synchronization"
        elsif high > 0
          "WARNING: #{high} inputs require synchronization"
        else
          "All crossings analyzed. Review recommendations."
        end
      end
    end
  end
end
