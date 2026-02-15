module Yosys2Digitaljs
  class PrimitiveProcessor
    def initialize(converter)
      @converter = converter
    end

    def process(name, cell, type, original_type = nil)
      dev_id = @converter.sanitized_id(name)
      params = cell['parameters'] || {}
      
      args = {
        'type' => type,
        'label' => name
      }
      
      if @converter.options[:propagation]
         args['propagation'] = @converter.options[:propagation]
      end
      
      if cell['attributes'] && cell['attributes']['src']
         args['source_positions'] = @converter.parse_source_positions(cell['attributes']['src'])
      end
      
      # Handle explicit Subcircuit or generic module instance
      if type == 'Subcircuit' || (original_type && original_type != 'Subcircuit')
         args['celltype'] = original_type || cell['type']
         args['type'] = 'Subcircuit'
         
         if cell['attributes'] && cell['attributes']['src']
            args['source_positions'] = @converter.parse_source_positions(cell['attributes']['src'])
         end

      elsif ['$constant', 'Constant'].include?(cell['type'])
         args['type'] = 'Constant'
         args['bits'] = params['WIDTH'].to_i if params['WIDTH']
         args['constant'] = (params['VALUE'] || 0).to_s(2).rjust(args['bits'] || 1, '0')

      elsif ['$neg', '$pos'].include?(cell['type'])
        args['bits'] = {
          'in' => cell['connections']['A'].size,
          'out' => cell['connections']['Y'].size
        }
        args['signed'] = (params['A_SIGNED'].to_i == 1)
        
      elsif cell['type'] == '$not'
        match_port(cell['connections']['A'], params['A_WIDTH'], params['A_SIGNED'])
        args['bits'] = cell['connections']['Y'].size

      elsif ['$add', '$sub', '$mul', '$div', '$mod', '$pow'].include?(cell['type'])
        args['bits'] = {
          'in1' => cell['connections']['A'].size,
          'in2' => cell['connections']['B'].size,
          'out' => cell['connections']['Y'].size
        }
        args['signed'] = {
          'in1' => (params['A_SIGNED'].to_i == 1),
          'in2' => (params['B_SIGNED'].to_i == 1)
        }
        
      elsif ['$eq', '$ne', '$lt', '$le', '$gt', '$ge', '$eqx', '$nex'].include?(cell['type'])
        args['bits'] = {
          'in1' => cell['connections']['A'].size,
          'in2' => cell['connections']['B'].size
        }
        args['signed'] = {
           'in1' => (params['A_SIGNED'].to_i == 1),
           'in2' => (params['B_SIGNED'].to_i == 1)
        }
        zero_extend_output(cell['connections']['Y'])

      elsif ['$shl', '$shr', '$sshl', '$sshr', '$shift', '$shiftx'].include?(cell['type'])
        args['bits'] = {
          'in1' => cell['connections']['A'].size,
          'in2' => cell['connections']['B'].size,
          'out' => cell['connections']['Y'].size
        }
        is_shift_x = ['$shift', '$shiftx'].include?(cell['type'])
        is_sshl_r  = ['$sshl', '$sshr'].include?(cell['type'])
        
        args['signed'] = {
           'in1' => (params['A_SIGNED'].to_i == 1),
           'in2' => (params['B_SIGNED'].to_i == 1 && is_shift_x),
           'out' => (params['A_SIGNED'].to_i == 1 && is_sshl_r)
        }
        args['fillx'] = true if cell['type'] == '$shiftx'
        
      elsif cell['type'] == '$mux'
         args['bits'] = {
           'in' => params['WIDTH'].to_i,
           'sel' => 1
         }
         
      elsif ['$dff', '$dffe', '$adff', '$adffe', '$sdff', '$sdffe', '$sdffce', '$dlatch', '$adlatch', '$dffsr', '$dffsre', '$aldff', '$aldffe', '$sr'].include?(cell['type'])
         args['bits'] = params['WIDTH'].to_i
         args['polarity'] = extract_polarity(params)
         
         if ['$adff', '$adffe', '$adlatch'].include?(cell['type'])
             args['arst_value'] = decode_constant(params['ARST_VALUE'], args['bits'])
         end
         
         if ['$sdff', '$sdffe', '$sdffce'].include?(cell['type'])
             args['srst_value'] = decode_constant(params['SRST_VALUE'], args['bits'])
             if cell['type'] == '$sdffce'
                 args['enable_srst'] = true
             end
         end
         
         if cell['type'] == '$sr'
             args['no_data'] = true
         end

         if cell['connections']['Q']
            initial_val = find_initial_value(cell['connections']['Q'])
            args['initial'] = initial_val if initial_val
         end

      elsif ['$logic_and', '$logic_or'].include?(cell['type'])
        reduce_input(cell['connections']['A']) if cell['connections']['A'].size > 1
        reduce_input(cell['connections']['B']) if cell['connections']['B'].size > 1
        
        args['bits'] = 1
        zero_extend_output(cell['connections']['Y'])

      elsif ['$reduce_and', '$reduce_or', '$reduce_xor', '$reduce_xnor', '$reduce_bool', '$logic_not'].include?(cell['type'])
        args['bits'] = cell['connections']['A'].size
        zero_extend_output(cell['connections']['Y'])
        
        if args['bits'] == 1
           if ['$reduce_xnor', '$logic_not'].include?(cell['type'])
              args['type'] = 'Not'
           else
              args['type'] = 'Repeater'
           end
        end

      else
        if ['$and', '$or', '$xor', '$xnor'].include?(cell['type'])
            match_port(cell['connections']['A'], params['A_WIDTH'], params['A_SIGNED'])
            match_port(cell['connections']['B'], params['B_WIDTH'], params['B_SIGNED'])
        end
        
        args['bits'] = params['WIDTH'].to_i if params['WIDTH']
        if params['A_SIGNED'] || params['B_SIGNED']
           args['signed'] = (params['A_SIGNED'].to_i == 1) || (params['B_SIGNED'].to_i == 1)
        end
      end
      
      @converter.devices[dev_id] = args
      
      port_map = Converter.get_port_map(type)
      if port_map.nil? && args['type'] == 'Subcircuit'
          port_map = {}
          cell['connections'].keys.each do |k|
              port_map[k] = k
          end
      end
      
      connections = cell['connections']
      
      if port_map
        connections.each do |yosys_port, nets|
            djs_port = port_map[yosys_port]
            next unless djs_port
            
            nets.each_with_index do |net_id, i|
               @converter.connect_net(net_id, dev_id, djs_port, i)
            end
        end
      end
    end

    protected

    def extract_polarity(params)
        pol = {}
        pol['clock'] = (params['CLK_POLARITY'].to_i == 1) if params['CLK_POLARITY']
        pol['enable'] = (params['EN_POLARITY'].to_i == 1) if params['EN_POLARITY']
        pol['arst'] = (params['ARST_POLARITY'].to_i == 1) if params['ARST_POLARITY']
        pol['srst'] = (params['SRST_POLARITY'].to_i == 1) if params['SRST_POLARITY']
        pol['aload'] = (params['ALOAD_POLARITY'].to_i == 1) if params['ALOAD_POLARITY']
        pol['set'] = (params['SET_POLARITY'].to_i == 1) if params['SET_POLARITY']
        pol['clr'] = (params['CLR_POLARITY'].to_i == 1) if params['CLR_POLARITY']
        pol
    end

    def find_initial_value(q_nets)
        return nil unless @converter.current_module['netnames']
        
        @converter.current_module['netnames'].each do |name, net|
             if net['bits'].include?(q_nets.first)
                 if net['attributes'] && net['attributes']['init']
                      val = net['attributes']['init']
                      width = q_nets.size
                      return decode_constant(val, width)
                 end
             end
        end
        nil
    end

    def match_port(nets, width_param, signed_param)
        return unless width_param
        width = width_param.to_i
        return if nets.size >= width
        
        # Insert Extension
        # NOTE: CircuitVerse frontend only supports ZeroExtend, not SignExtend
        # Even for signed operations, we use ZeroExtend (slight semantic difference but functional)
        signed = (signed_param.to_i == 1)
        type = 'ZeroExtend'  # Always use ZeroExtend for compatibility
        ext_id = "ext_#{nets.object_id}" 
        
        args = {
            'type' => type,
            'extend' => { 'input' => nets.size, 'output' => width },
            'label' => "Ext"
        }
        @converter.devices[ext_id] = args
        
        # 2. Wire Original Nets -> Extension Input
        nets.each_with_index do |net, i|
            @converter.connect_net(net, ext_id, 'in', i)
        end
        
        # 3. Create New Intermediate Nets for Output
        
        new_nets = (0...width).map { |i| "ext_#{ext_id}_#{i}" }
        
        new_nets.each_with_index do |net, i|
             @converter.connect_net(net, ext_id, 'out', i)
        end
        
        # 4. Modify the 'nets' array in-place so the Gate connects to New Nets
        nets.replace(new_nets)
    end

    def decode_constant(val, bits)
      return val if val.is_a?(String)
      return val.to_i.to_s(2).rjust(bits, '0')
    end

    def reduce_input(nets)
      new_net_id = "intermediate_#{nets.join('_')}"
      dev_id = @converter.sanitized_id("reduce_#{new_net_id}")
      args = {
        'type' => 'OrReduce',
        'bits' => nets.size,
        'label' => "Reduce"
      }
      @converter.devices[dev_id] = args
      nets.each_with_index do |net, i|
         @converter.connect_net(net, dev_id, 'in', i)
      end
      
      # Output of reducer is 1 bit
      out_net = "reduced_#{new_net_id}"
      @converter.connect_net(out_net, dev_id, 'out', 0)
      
      nets.replace([out_net])
    end

    def zero_extend_output(nets)
       if nets.size > 1
           # Implementation:
           original_nets = nets.dup
           lsb = original_nets.first
           
           # Gate drives LSB
           nets.replace([lsb])
       end
    end
  end
end
