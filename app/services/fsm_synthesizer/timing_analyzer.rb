module FsmSynthesizer
  # TimingAnalyzer: Analyzes timing paths and constraints for FSM synthesis
  #
  # Purpose:
  #   Identifies critical paths (longest logic depth)
  #   Validates timing closure at specified clock frequency
  #   Reports margin information and optimization opportunities
  #
  # Timing Analysis Type:
  #   - Setup time path (combinational + FF setup)
  #   - Clock-to-Q propagation
  #   - Critical path identification
  #
  # Example:
  #   analyzer = FsmSynthesizer::TimingAnalyzer.new
  #   timing = analyzer.analyze_timing(fsm, equations, clock_freq_mhz)
  #   report = analyzer.get_timing_report

  class TimingAnalyzer
    attr_accessor :fsm
    attr_accessor :timing_data

    # Default technology library parameters (in nanoseconds)
    STANDARD_LIBRARY = {
      ff_setup: 0.2,      # Setup time
      ff_hold: 0.1,       # Hold time
      ff_clock_to_q: 0.4, # Clock-to-Q delay
      ff_propagation_delay: 0.2, # Internal FF delay
      
      and_delay: 0.05,    # 2-input AND gate delay
      or_delay: 0.05,     # 2-input OR gate delay
      not_delay: 0.02,    # NOT gate delay
      xor_delay: 0.08,    # XOR gate delay
      
      inverter_fanout: 4,       # Max fanout before degradation
      and_fanout: 3,
      or_fanout: 3,
      
      interconnect_delay_per_cell: 0.01 # Wiring delay
    }

    def initialize(library = STANDARD_LIBRARY)
      @library = library.merge(STANDARD_LIBRARY.select { |k, _| !library.key?(k) })
      @timing_data = {}
    end

    # Perform timing analysis on FSM synthesis
    #
    # Parameters:
    #   fsm - FSM object
    #   equations - Hash of equation_id => expression
    #   clock_freq_mhz - Target clock frequency
    #   options - Hash:
    #     :library - Custom technology library
    #     :report_paths - Boolean (default: false) - Include critical paths
    #     :num_paths - Number of paths to report (default: 5)
    #
    # Returns:
    #   Hash with timing analysis results
    def analyze_timing(fsm, equations, clock_freq_mhz, options = {})
      @fsm = fsm
      @timing_data = {
        target_freq_mhz: clock_freq_mhz,
        target_period_ns: 1000.0 / clock_freq_mhz,
        equations: equations,
        paths: {},
        critical_path: nil,
        timing_met: true,
        violations: []
      }

      # Analyze each equation for timing
      equations.each do |eq_id, expression|
        path_delay = calculate_expression_delay(expression)
        total_delay = path_delay + @library[:ff_setup]
        
        path_key = eq_id.to_s
        @timing_data[:paths][path_key] = {
          equation: eq_id,
          expression: expression,
          combinational_delay: path_delay,
          setup_time: @library[:ff_setup],
          total_delay: total_delay,
          slack: @timing_data[:target_period_ns] - total_delay,
          meets_timing: total_delay <= @timing_data[:target_period_ns]
        }

        # Track violations
        unless @timing_data[:paths][path_key][:meets_timing]
          @timing_data[:violations] << {
            path: path_key,
            delay: total_delay,
            slack: @timing_data[:target_period_ns] - total_delay,
            violation_amount: total_delay - @timing_data[:target_period_ns]
          }
        end
      end

      # Find critical path
      @timing_data[:critical_path] = @timing_data[:paths].max_by { |_, p| p[:total_delay] }
      
      # Check if timing is met
      @timing_data[:timing_met] = @timing_data[:violations].empty?

      # Generate report if requested
      if options[:report_paths]
        @timing_data[:critical_paths] = get_critical_paths(options.fetch(:num_paths, 5))
      end

      # Add optimization recommendations
      @timing_data[:recommendations] = generate_recommendations

      @timing_data
    end

    # Get timing analysis report
    #
    # Returns:
    #   Hash with formatted report
    def get_timing_report
      {
        summary: {
          target_frequency_mhz: @timing_data[:target_freq_mhz],
          target_period_ns: @timing_data[:target_period_ns].round(2),
          timing_closure: @timing_data[:timing_met] ? 'PASS' : 'FAIL',
          num_violations: @timing_data[:violations].length,
          critical_path_delay: (@timing_data[:critical_path]&.[]&.(1)&.[](:total_delay) || 0).round(3)
        },
        violations: @timing_data[:violations].map do |violation|
          {
            path: violation[:path],
            delay_ns: violation[:delay].round(3),
            slack_ns: violation[:slack].round(3),
            violation_ns: violation[:violation_amount].round(3)
          }
        end,
        critical_paths: @timing_data[:critical_paths] || [],
        recommendations: @timing_data[:recommendations],
        library_parameters: {
          ff_clock_to_q: @library[:ff_clock_to_q],
          ff_setup: @library[:ff_setup],
          ff_hold: @library[:ff_hold],
          gate_delays: {
            and: @library[:and_delay],
            or: @library[:or_delay],
            not: @library[:not_delay],
            xor: @library[:xor_delay]
          }
        }
      }
    end

    # Calculate combinational delay through expression
    #
    # Parameters:
    #   expression - Boolean expression string
    #
    # Returns:
    #   Float delay in nanoseconds
    def calculate_expression_delay(expression)
      return 0.0 if expression.blank?

      # Count gates and estimate critical path
      # For simplicity, use depth-based estimation
      
      critical_depth = estimate_expression_depth(expression)
      
      # Average gate delay (weighted by type frequencies)
      avg_gate_delay = (
        @library[:and_delay] +
        @library[:or_delay] +
        @library[:not_delay]
      ) / 3.0

      # Total delay = critical_depth * avg_gate_delay + interconnect
      total_delay = (critical_depth * avg_gate_delay) + 
                   (@library[:interconnect_delay_per_cell] * critical_depth)

      total_delay
    end

    # Check if timing is met at frequency
    #
    # Returns:
    #   Boolean
    def is_timing_met?
      @timing_data[:timing_met]
    end

    # Get required frequency for critical path
    #
    # Returns:
    #   Float frequency in MHz
    def get_achievable_frequency
      critical_delay = @timing_data[:critical_path]&.[]&.(1)&.[](:total_delay)
      return 0.0 unless critical_delay && critical_delay > 0

      (1000.0 / critical_delay).round(1)
    end

    # Get timing slack margin
    #
    # Returns:
    #   Float slack in nanoseconds
    def get_worst_case_slack
      worst_slack = @timing_data[:critical_path]&.[]&.(1)&.[](:slack)
      worst_slack || 0.0
    end

    # Private helper methods

    private

    def estimate_expression_depth(expression)
      # Estimate logic depth (longest path from inputs to output)
      # Simple heuristic: count nesting levels
      
      depth = 0
      current_depth = 0
      
      expression.each_char do |char|
        case char
        when '('
          current_depth += 1
          depth = [depth, current_depth].max
        when ')'
          current_depth -= 1
        end
      end

      # Minimum depth of 1 for any expression
      [depth, 1].max
    end

    def get_critical_paths(num_paths)
      # Get top N paths by delay
      paths = @timing_data[:paths].sort_by { |_, p| -p[:total_delay] }
      
      paths[0..num_paths - 1].map do |path_id, path_info|
        {
          path: path_id,
          delay_ns: path_info[:total_delay].round(3),
          expression: path_info[:expression],
          slack_ns: path_info[:slack].round(3)
        }
      end
    end

    def generate_recommendations
      recommendations = []

      # Check for paths close to violation
      margin_warning = @timing_data[:target_period_ns] * 0.1 # 10% margin

      @timing_data[:paths].each do |path_id, path_info|
        slack = path_info[:slack]
        
        if slack < margin_warning && slack > 0
          recommendations << {
            path: path_id,
            type: 'margin_warning',
            message: "Path has low timing margin (#{slack.round(3)} ns). Consider optimization.",
            suggestion: 'Simplify expression logic or increase clock frequency tolerance'
          }
        elsif slack <= 0
          recommendations << {
            path: path_id,
            type: 'violation',
            message: "Path violates timing (slack: #{slack.round(3)} ns)",
            suggestion: 'Apply equation optimization or increase clock period'
          }
        end
      end

      # Frequency recommendation
      if !is_timing_met?
        max_safe_freq = get_achievable_frequency * 0.9  # 90% safety margin
        recommendations << {
          type: 'frequency_recommendation',
          current_target_mhz: @timing_data[:target_freq_mhz],
          recommended_mhz: max_safe_freq.round(1),
          message: "Current target frequency #{@timing_data[:target_freq_mhz]} MHz is not achievable",
          suggestion: "Reduce frequency to #{max_safe_freq.round(1)} MHz or optimize logic"
        }
      end

      recommendations
    end
  end
end
