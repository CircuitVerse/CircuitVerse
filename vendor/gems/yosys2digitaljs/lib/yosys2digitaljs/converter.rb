require 'tsort'
require_relative 'primitive_processor'
require_relative 'net_grouper'
require_relative 'constant_processor'
require_relative 'io_ui_processor'
require_relative 'fsm_processor'
require_relative 'pmux_processor'
require_relative 'memory_processor'

module Yosys2Digitaljs
  class Converter
    class Error < StandardError; end

    include TSort

    attr_reader :netmap, :devices, :connectors, :constants, :current_module, :subcircuits, :options

    def initialize(json, options = {})
      @json = json
      @modules = json['modules']
      @options = options || {}
      
      @devices = {}
      @connectors = []
      @netmap = {} 
      @constants = {}
      @subcircuits = {}
      
      @current_module = nil
    end

    def tsort_each_node(&block)
      @modules.each_key(&block)
    end

    def tsort_each_child(node, &block)
      mod = @modules[node]
      mod['cells'].each do |_, cell|
        block.call(cell['type']) if @modules.key?(cell['type'])
      end
    end

    def convert
      raise Error, "No modules found in JSON" if @modules.nil? || @modules.empty?

      sorted_modules = tsort
      
      final_output = nil
      top_module_name = @modules.keys.find { |k| @modules[k]['attributes'] && @modules[k]['attributes']['top'] == 1 } || sorted_modules.last

      sorted_modules.each do |mod_name|
         result = process_single_module(mod_name)
         
         if mod_name == top_module_name
            final_output = result
         else
            @subcircuits[mod_name] = result
         end
      end

      final_output[:subcircuits] = @subcircuits
      final_output[:name] = top_module_name
      final_output
    end
    
    def process_single_module(mod_name)
      @devices = {}
      @connectors = []
      @netmap = {}
      @constants = {}
      @current_module = @modules[mod_name]
      
      process_module(@current_module)
      ConstantProcessor.new(self).process
      build_connectors
      @connectors = NetGrouper.new(self).compress_connectors(@connectors)
      IoUiProcessor.process(@devices)

      {
        devices: @devices,
        connectors: @connectors
      }
    end
    
    def parse_source_positions(str)
       return [] unless str
       positions = []
       str.split('|').each do |entry|
          last_colon = entry.rindex(':')
          next unless last_colon
          
          filename = entry[0...last_colon]
          range_part = entry[(last_colon + 1)..-1]
          from_str, to_str = range_part.split('-')
          next unless from_str && to_str
          
          from = parse_csv_coords(from_str)
          to = parse_csv_coords(to_str)
          
          positions << {
             'name' => filename,
             'from' => from,
             'to' => to
          }
       end
       positions
    end

    def parse_csv_coords(str)
       line, col = str.split('.').map(&:to_i)
       { 'line' => line, 'column' => col }
    end

    def sanitized_id(name)
      # Ensure valid ID (alphanumeric + underscore)
      name.gsub(/[^a-zA-Z0-9_]/, '_')
    end
    
    # -- Core Processing Logic --
    
    def process_module(mod)
      @current_module = mod
      # 1. Process Ports (Inputs/Outputs)
      mod['ports'].each do |name, port|
        dir = port['direction']
        bits = port['bits']
        type = (dir == 'input') ? 'Input' : (dir == 'output' ? 'Output' : nil)
        next unless type
        
        dev_id = sanitized_id(name)
        @devices[dev_id] = {
           'type' => type,
           'label' => name,
           'net' => name,
           'bits' => bits.size
        }
        
        if type == 'Input'
           bits.each_with_index do |net_id, i|
             connect_net(net_id, dev_id, 'out', i)
           end
        else # Output
           bits.each_with_index do |net_id, i|
             connect_net(net_id, dev_id, 'in', i)
           end
        end
      end

      # 2. Process Cells (Gates)
      mod['cells'].each do |name, cell|
        type = cell['type']
        
        if ['$mem', '$mem_v2', '$lut'].include?(type)
             MemoryProcessor.new(self).process(name, cell)
        elsif type == '$fsm'
             FsmProcessor.new(self).process(name, cell)
        elsif type == '$pmux'
             PmuxProcessor.new(self).process(name, cell)
        elsif GATE_SUBST[type]
             PrimitiveProcessor.new(self).process(name, cell, GATE_SUBST[type])
        elsif @subcircuits.key?(type) || @modules.key?(type)
             # SUBMODULE INSTANCE
             # PrimitiveProcessor will handle generic 'Subcircuit' type logic
             PrimitiveProcessor.new(self).process(name, cell, 'Subcircuit', type)
        else
            # TODO: Handle unknown gates or submodules
            warn "Warning: Unknown gate type #{type}"
        end
      end
      # 3. Process Net Attributes (Source Positions)
      if mod['netnames']
         mod['netnames'].each do |net_name, data|
             next if data['hide_name'] == 1
             next unless data['attributes'] && data['attributes']['src']
             
             src_positions = parse_source_positions(data['attributes']['src'])
             next if src_positions.empty?
             
         end
      end
    end

    def connect_net(net_id, dev_id, port, bit)
      # Track net usage (id can be int or string)
      if ['0', '1', 'x', 'z'].include?(net_id.to_s)
         @constants[net_id.to_s] ||= []
         @constants[net_id.to_s] << { id: dev_id, port: port, bit: bit }
         return
      end
      
      @netmap[net_id] ||= []
      @netmap[net_id] << { id: dev_id, port: port, bit: bit }
    end
    
    def build_connectors
        # Connect one source to multiple targets
        
        @netmap.each do |net_id, points|
           sources = points.select { |p| is_source?(p[:id], p[:port]) }
           targets = points.select { |p| !is_source?(p[:id], p[:port]) }
           
            sources.each do |src|
               targets.each do |dst|
                  @connectors << {
                     'from' => { 'id' => src[:id], 'port' => src[:port] },
                     'to'   => { 'id' => dst[:id], 'port' => dst[:port] },
                     'name' => net_id.to_s
                  }
               end
            end
        end
    end
    
    def is_source?(dev_id, port)
       # Check if port is an output source
       dev = @devices[dev_id]
       return false unless dev
       
       type = dev['type']
       
       # Known output ports map
       # Check standard gates
       return true if port == 'out' # Output of gates, Input device
       return true if port == 'Q'   # DFF output
       
      
       if type == 'Subcircuit'
           # Look up module definition
           mod_def = @modules[dev['celltype']]
           if mod_def
               mod_port = mod_def['ports'][port] # wait, 
               return true if mod_def['ports'][port] && mod_def['ports'][port]['direction'] == 'output'
           end
       end
       
       false
    end

    # Static map for standard gates
    GATE_SUBST = {
      '$not' => 'Not',
      '$and' => 'And',
      '$nand' => 'Nand',
      '$or' => 'Or',
      '$nor' => 'Nor',
      '$xor' => 'Xor',
      '$xnor' => 'Xnor',
      '$reduce_and' => 'AndReduce',
      '$reduce_nand' => 'NandReduce',
      '$reduce_or' => 'OrReduce',
      '$reduce_nor' => 'NorReduce',
      '$reduce_xor' => 'XorReduce',
      '$reduce_xnor' => 'XnorReduce',
      '$reduce_bool' => 'OrReduce',
      '$logic_not' => 'NorReduce',
      '$repeater' => 'Repeater',
      '$shl' => 'ShiftLeft',
      '$shr' => 'ShiftRight',
      '$lt' => 'Lt',
      '$le' => 'Le',
      '$eq' => 'Eq',
      '$ne' => 'Ne',
      '$gt' => 'Gt',
      '$ge' => 'Ge',
      '$constant' => 'Constant',
      '$neg' => 'Negation',
      '$pos' => 'Repeater',
      '$add' => 'Addition',
      '$sub' => 'Subtraction',
      '$mul' => 'Multiplication',
      '$div' => 'Division',
      '$mod' => 'Modulo',
      '$pow' => 'Power',
      '$mux' => 'Mux',
      '$pmux' => 'Mux1Hot',
      '$mem' => 'Memory',
      '$clock' => 'Clock',
      '$button' => 'Button',
      '$lamp' => 'Lamp',
      '$dff' => 'Dff',
      '$dffe' => 'Dff',
      '$adff' => 'Dff',
      '$adffe' => 'Dff',
      '$sdff' => 'Dff',
      '$sdffe' => 'Dff',
      '$sdffce' => 'Dff',
      '$dlatch' => 'Dff',
      '$adlatch' => 'Dff',
      '$dffsr' => 'Dff',
      '$dffsre' => 'Dff',
      '$aldff' => 'Dff',
      '$aldffe' => 'Dff',
      '$sr' => 'Dff',
      '$logic_and' => 'And',
      '$logic_or' => 'Or'
    }

    def self.get_port_map(type)
      # Define port mappings for standard gates
      # Yosys Port -> DigitalJS Port (matching CircuitVerse frontend expectations)
      
      # Unary gates (single input)
      return { 'A' => 'in', 'Y' => 'out' } if ['Not', 'Repeater', 'Negation', 'AndReduce', 'OrReduce', 'XorReduce', 'NandReduce', 'NorReduce', 'XnorReduce'].include?(type)
      
      # Binary gates (two inputs)
      return { 'A' => 'in1', 'B' => 'in2', 'Y' => 'out' } if ['And', 'Nand', 'Or', 'Nor', 'Xor', 'Xnor', 'Addition', 'Subtraction', 'Multiplication', 'Division', 'Modulo', 'Power', 'ShiftLeft', 'ShiftRight', 'Lt', 'Le', 'Eq', 'Ne', 'Gt', 'Ge'].include?(type)
      
      # Multiplexers
      return { 'A' => 'in0', 'B' => 'in1', 'S' => 'sel', 'Y' => 'out' } if type == 'Mux'
      return { 'A' => 'in0', 'B' => 'in1', 'S' => 'sel', 'Y' => 'out' } if type == 'Mux1Hot'

      # Constants and sources (output only)
      return { 'Y' => 'out' } if ['Constant', 'Clock', 'Button'].include?(type)
      
      # Sinks (input only)
      return { 'A' => 'in' } if type == 'Lamp'

      # Extension operations
      return { 'A' => 'in', 'Y' => 'out' } if ['ZeroExtend', 'SignExtend'].include?(type)

      # DFF (Flip-Flop)
      if type == 'Dff'
          return { 'D' => 'in', 'Q' => 'out', 'CLK' => 'clk', 'EN' => 'en', 'ARST' => 'arst', 'SRST' => 'srst', 'ALOAD' => 'aload', 'AD' => 'ain', 'SET' => 'set', 'CLR' => 'clr' }
      end

      # Bus operations
      return { 'in' => 'in', 'out' => 'out' } if ['BusSlice', 'BusGroup', 'BusUngroup'].include?(type)

      # Memory has complex port structure, handled separately
      return nil if type == 'Memory'
      
      # Subcircuit? Ports are dynamic.
      nil
    end
  end
end
