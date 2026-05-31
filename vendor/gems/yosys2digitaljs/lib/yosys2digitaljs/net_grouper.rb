module Yosys2Digitaljs
  class NetGrouper
    def initialize(converter)
      @converter = converter
      @devices = converter.devices
      @netmap = converter.netmap
    end

    def compress_connectors(connectors)
      by_target = Hash.new { |h, k| h[k] = [] }
      connectors.each do |c|
        target_key = [c['to']['id'], c['to']['port']]
        # Pre-calculate and attach bit index to avoid collision on replicated nets
        c['bit_index'] = find_target_bit_index(target_id_from_key(target_key), target_port_from_key(target_key), c['name'])
        by_target[target_key] << c
      end
      
      final_connectors = []
      
      by_target.each do |(target_id, target_port), conns|
        sources = Hash.new { |h, k| h[k] = [] }
        conns.each do |c|
           src_key = [c['from']['id'], c['from']['port']]
           # Use the pre-calculated bit index
           bit_index = c['bit_index']
           sources[src_key] << { conn: c, bit: bit_index }
        end
        
        if sources.size == 1
           src_list = sources.values.first
           src_list.sort_by! { |x| x[:bit] }
           
           merged = src_list.first[:conn].dup
           merged['name'] = src_list.map { |x| x[:conn]['name'] }.join(',')
           final_connectors << merged
        else
           all_bits = []
           sources.each do |src_key, list|
             list.each { |item| all_bits << item.merge(src_key: src_key) }
           end
           all_bits.sort_by! { |x| x[:bit] }
           
           total_width = all_bits.last[:bit] + 1
           
           msbs = all_bits.select { |x| x[:src_key][0].start_with?('const') }
           
           zero_extend_candidate = false
           
           final_connectors.concat(create_bus_group(target_id, target_port, all_bits, total_width))
        end
      end
      
      final_connectors
    end
    
    def find_target_bit_index(dev_id, port, net_id_str)
       net_id = net_id_str
       
       key = (net_id =~ /^\d+$/) ? net_id.to_i : net_id
       
       locations = @netmap[key]
       if locations
         loc = locations.find { |l| l[:id] == dev_id && l[:port] == port }
         return loc[:bit] if loc
       end
       
       # If not in netmap (e.g. Constant), we check `@converter.constants`?
       if @converter.constants[net_id]
          usages = @converter.constants[net_id]
          loc = usages.find { |l| l[:id] == dev_id && l[:port] == port }
          return loc[:bit] if loc
       end
       
       0
    end
    
    def create_bus_group(target_id, target_port, all_bits, total_width)
      groups = []
      current_group = []
      last_src = nil
       
      all_bits.each do |b|
         if last_src != nil && b[:src_key] != last_src
            groups << current_group
            current_group = []
         end
         current_group << b
         last_src = b[:src_key]
      end
      groups << current_group unless current_group.empty?
       
      bg_id = @converter.sanitized_id("bg_#{target_id}_#{target_port}")
       if groups.size == 2 && is_constant_zero(groups[1])
           # Zero Extend!
           lsb_group = groups[0]
           
           ext_args = {
             'type' => 'ZeroExtend',
             'extend' => { 'input' => lsb_group.size, 'output' => total_width },
             'label' => 'ZE'
           }
           @converter.devices[bg_id] = ext_args
           
           # Connect LSB Source -> ZE 'in'
           s_conn = lsb_group.first[:conn]
           # Force the 'to' to be ZE
           s_conn['to'] = { 'id' => bg_id, 'port' => 'in' }
           # Ensure name is merged
           s_conn['name'] = lsb_group.map { |x| x[:conn]['name'] }.join(',')
           add_connector(s_conn)
           
           # Connect ZE 'out' -> Target
           out_conn = {
             'from' => { 'id' => bg_id, 'port' => 'out' },
             'to' => { 'id' => target_id, 'port' => target_port },
             'name' => "ze_out"
           }
           # Return both
           [s_conn, out_conn]
           
       else
           # Generic Bus Group
           bg_args = {
             'type' => 'BusGroup',
             'groups' => groups.map(&:size)
           }
           @converter.devices[bg_id] = bg_args
           
           result_conns = []
           
           # Connect Sources -> BusGroup ('in0', 'in1'...)
           groups.each_with_index do |grp, i|
              conn_ref = grp.first[:conn]
              # We modify it to point to BusGroup input
              conn_ref['to'] = { 'id' => bg_id, 'port' => "in#{i}" }
              conn_ref['name'] = grp.map { |x| x[:conn]['name'] }.join(',')
              result_conns << conn_ref
           end
           
           # Connect BusGroup Out -> Target
           out_conn = {
             'from' => { 'id' => bg_id, 'port' => 'out' },
             'to' => { 'id' => target_id, 'port' => target_port },
             'name' => "bg_out"
           }
           result_conns << out_conn
           result_conns
       end
    end
    
    def is_constant_zero(group)
       src_id = group.first[:src_key][0]
       dev = @converter.devices[src_id]
       return false unless dev
       return false unless dev['type'] == 'Constant'
       dev['constant'].chars.all? { |c| c == '0' }
    end
    
    def add_connector(c)
    end
    
    private
    
    def target_id_from_key(key)
      key[0]
    end
    
    def target_port_from_key(key)
      key[1]
    end
  end
end
