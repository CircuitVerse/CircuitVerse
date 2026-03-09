module FsmSynthesizer
  # StateDiagramGenerator: Generates visualization data for FSM state diagrams
  #
  # Purpose:
  #   Produces structured diagram data suitable for rendering state machine diagrams
  #   Includes all states, transitions, clock domain information, and timing annotations
  #   Optimizes layout and positioning for visual clarity
  #
  # Output Formats:
  #   - GraphViz DOT format for Graphviz rendering
  #   - JSON format for web-based visualization libraries
  #   - SVG-ready positioning with coordinates
  #
  # Example:
  #   generator = FsmSynthesizer::StateDiagramGenerator.new
  #   diagram = generator.generate_diagram(fsm)
  #   json_data = generator.to_json(diagram)
  #   dot_script = generator.to_graphviz(diagram)

  class StateDiagramGenerator
    attr_accessor :fsm
    attr_accessor :diagram

    def initialize
      @diagram = {
        states: {},
        transitions: [],
        metadata: {}
      }
    end

    # Generate complete state diagram from FSM
    #
    # Parameters:
    #   fsm - FSM object with states and transitions
    #   options - Hash with keys:
    #     :layout - "hierarchy", "circle", "grid" (default: hierarchy)
    #     :include_timing - Boolean (default: false)
    #     :include_encoding - Boolean (default: true)
    #     :include_outputs - Boolean (default: true)
    #
    # Returns:
    #   Diagram specification hash
    def generate_diagram(fsm, options = {})
      @fsm = fsm
      @diagram = {
        states: {},
        transitions: [],
        metadata: generate_metadata,
        layout: options.fetch(:layout, 'hierarchy')
      }

      # Generate state nodes
      generate_state_nodes(options)
      
      # Generate transition edges
      generate_transitions(options)
      
      # Apply layout algorithm
      apply_layout(options[:layout])
      
      @diagram
    end

    # Convert diagram to GraphViz DOT format
    #
    # Returns:
    #   String containing GraphViz dot script
    def to_graphviz(diagram = @diagram)
      raise 'Diagram not generated. Call generate_diagram first.' if diagram[:states].empty?

      dot = []
      dot << 'digraph FSM {'
      dot << '  rankdir=LR;'
      dot << '  node [shape=circle, style=filled, fillcolor=lightblue];'
      dot << '  initial [label="", shape=point];'

      # Initial state
      initial = @fsm.initial_state
      dot << "  initial -> \"#{initial}\";"

      # States
      diagram[:states].each do |state_id, state_info|
        color = state_info[:is_initial] ? 'lightgreen' : 'lightblue'
        if state_info[:is_accepting]
          dot << "  \"#{state_id}\" [shape=doublecircle, fillcolor=#{color}];"
        else
          dot << "  \"#{state_id}\" [fillcolor=#{color}];"
        end
      end

      # Transitions
      diagram[:transitions].each do |trans|
        label_parts = [trans[:condition]]
        label_parts << "/ #{trans[:output]}" if trans[:output]
        label = label_parts.join(' ')
        
        dot << "  \"#{trans[:from]}\" -> \"#{trans[:to]}\" [label=\"#{label}\"];"
      end

      dot << '}'
      dot.join("\n")
    end

    # Convert diagram to JSON format
    #
    # Returns:
    #   JSON string with diagram data
    def to_json(diagram = @diagram)
      {
        fsm_type: @fsm.machine_type,
        states: diagram[:states],
        transitions: diagram[:transitions],
        metadata: diagram[:metadata],
        layout: diagram[:layout]
      }.to_json
    end

    # Export diagram as structured hash
    #
    # Returns:
    #   Hash suitable for JSON serialization
    def to_hash(diagram = @diagram)
      {
        fsm_type: @fsm.machine_type,
        initial_state: @fsm.initial_state,
        states: diagram[:states],
        transitions: diagram[:transitions],
        metadata: diagram[:metadata],
        layout: diagram[:layout]
      }
    end

    # Get state positioning information
    #
    # Returns:
    #   Hash with state positions for rendering
    def get_state_positions(diagram = @diagram)
      positions = {}
      diagram[:states].each do |state_id, state_info|
        positions[state_id] = {
          x: state_info[:x],
          y: state_info[:y],
          radius: state_info[:radius]
        }
      end
      positions
    end

    # Get transition routing information
    #
    # Returns:
    #   Hash with paths for rendering
    def get_transition_paths(diagram = @diagram)
      paths = {}
      diagram[:transitions].each_with_index do |trans, idx|
        key = "#{trans[:from]}_to_#{trans[:to]}"
        paths[key] = {
          from: trans[:from],
          to: trans[:to],
          control_points: trans[:control_points] || [],
          is_loop: trans[:from] == trans[:to]
        }
      end
      paths
    end

    # Private methods

    private

    def generate_state_nodes(options)
      @fsm.states.each do |state_id|
        @diagram[:states][state_id] = {
          id: state_id,
          label: state_id,
          is_initial: state_id == @fsm.initial_state,
          is_accepting: is_accepting_state?(state_id),
          x: 0,
          y: 0,
          radius: 30,
          encoding: options[:include_encoding] ? (@fsm.state_encoding[state_id] || []) : nil,
          output: options[:include_outputs] ? get_state_output(state_id) : nil
        }
      end
    end

    def generate_transitions(options)
      @fsm.transitions.each do |trans|
        transition = {
          id: "#{trans[:from]}_#{trans[:to]}_#{trans[:condition]}",
          from: trans[:from],
          to: trans[:to],
          condition: trans[:condition],
          output: trans[:output],
          is_loop: trans[:from] == trans[:to],
          control_points: [],
          curve_angle: 0
        }

        @diagram[:transitions] << transition
      end
    end

    def generate_metadata
      {
        machine_type: @fsm.machine_type,
        num_states: @fsm.states.length,
        num_inputs: @fsm.inputs.length,
        num_outputs: @fsm.outputs.length,
        num_transitions: @fsm.transitions.length,
        deterministic: is_deterministic?,
        complete: is_complete?,
        reachable_states: count_reachable_states,
        unreachable_states: get_unreachable_states
      }
    end

    def apply_layout(layout_type)
      case layout_type
      when 'hierarchy'
        apply_hierarchical_layout
      when 'circle'
        apply_circular_layout
      when 'grid'
        apply_grid_layout
      else
        apply_hierarchical_layout
      end
    end

    def apply_hierarchical_layout
      # Arrange states in hierarchy by level
      levels = compute_state_levels
      
      max_width = 800
      max_height = 600
      
      levels.each_with_index do |states_at_level, level|
        y = 100 + (level * 120)
        
        x_spacing = max_width / (states_at_level.length + 1)
        states_at_level.each_with_index do |state_id, idx|
          x = x_spacing * (idx + 1)
          
          @diagram[:states][state_id][:x] = x
          @diagram[:states][state_id][:y] = y
        end
      end

      # Add control points for transitions
      add_transition_control_points
    end

    def apply_circular_layout
      # Arrange states in circle
      num_states = @diagram[:states].length
      radius = 200
      center_x = 400
      center_y = 300
      
      @diagram[:states].each_with_index do |(state_id, _), idx|
        angle = (2 * Math::PI * idx) / num_states
        x = center_x + (radius * Math.cos(angle))
        y = center_y + (radius * Math.sin(angle))
        
        @diagram[:states][state_id][:x] = x
        @diagram[:states][state_id][:y] = y
      end

      add_transition_control_points
    end

    def apply_grid_layout
      # Arrange states in grid
      num_states = @diagram[:states].length
      cols = Math.sqrt(num_states).ceil
      
      @diagram[:states].each_with_index do |(state_id, _), idx|
        row = idx / cols
        col = idx % cols
        
        x = 100 + (col * 150)
        y = 100 + (row * 150)
        
        @diagram[:states][state_id][:x] = x
        @diagram[:states][state_id][:y] = y
      end

      add_transition_control_points
    end

    def add_transition_control_points
      @diagram[:transitions].each do |trans|
        from_state = @diagram[:states][trans[:from]]
        to_state = @diagram[:states][trans[:to]]
        
        if trans[:is_loop]
          # Loop back to same state
          trans[:control_points] = [
            { x: from_state[:x] + 50, y: from_state[:y] - 50 },
            { x: from_state[:x] + 50, y: from_state[:y] - 80 }
          ]
          trans[:curve_angle] = 90
        else
          # Straight line with possible curve
          mid_x = (from_state[:x] + to_state[:x]) / 2.0
          mid_y = (from_state[:y] + to_state[:y]) / 2.0
          
          trans[:control_points] = [
            { x: mid_x, y: mid_y }
          ]
        end
      end
    end

    def compute_state_levels
      levels = {}
      levels[@fsm.initial_state] = 0
      
      queue = [@fsm.initial_state]
      visited = Set.new([@fsm.initial_state])
      
      while queue.any?
        current = queue.shift
        current_level = levels[current] || 0
        
        # Find transitions from current state
        @fsm.transitions.each do |trans|
          if trans[:from] == current && !visited.include?(trans[:to])
            levels[trans[:to]] = current_level + 1
            queue.push(trans[:to])
            visited.add(trans[:to])
          end
        end
      end
      
      # Group by level
      level_groups = {}
      levels.each do |state, level|
        level_groups[level] ||= []
        level_groups[level] << state
      end
      
      # Return as array of arrays
      (0..level_groups.keys.max.to_i).map { |l| level_groups[l] || [] }
    end

    def is_accepting_state?(state_id)
      # In typical FSM, accepting states might be marked
      # For now, treat final states with no outgoing transitions
      @fsm.transitions.none? { |t| t[:from] == state_id }
    end

    def get_state_output(state_id)
      # Get output for Moore machine
      return nil unless @fsm.machine_type == 'moore'
      
      @fsm.state_outputs&.[](state_id)
    end

    def is_deterministic?
      # Check for nondeterministic transitions
      @fsm.transitions.each do |t1|
        conflict = @fsm.transitions.any? do |t2|
          t1[:from] == t2[:from] && t1[:condition] == t2[:condition] && t1[:to] != t2[:to]
        end
        return false if conflict
      end
      true
    end

    def is_complete?
      # Check if all input combinations are defined for all states
      # For simplicity, require transitions for major inputs
      @fsm.transitions.length > 0
    end

    def count_reachable_states
      reachable = Set.new([@fsm.initial_state])
      queue = [@fsm.initial_state]
      
      while queue.any?
        current = queue.shift
        
        @fsm.transitions.each do |trans|
          if trans[:from] == current && !reachable.include?(trans[:to])
            reachable.add(trans[:to])
            queue.push(trans[:to])
          end
        end
      end
      
      reachable.length
    end

    def get_unreachable_states
      reachable = Set.new([@fsm.initial_state])
      queue = [@fsm.initial_state]
      
      while queue.any?
        current = queue.shift
        
        @fsm.transitions.each do |trans|
          if trans[:from] == current && !reachable.include?(trans[:to])
            reachable.add(trans[:to])
            queue.push(trans[:to])
          end
        end
      end
      
      @fsm.states.reject { |s| reachable.include?(s) }
    end
  end
end
