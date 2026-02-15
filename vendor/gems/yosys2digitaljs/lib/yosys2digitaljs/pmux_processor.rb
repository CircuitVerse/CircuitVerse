module Yosys2Digitaljs
  class PmuxProcessor
    def initialize(converter)
      @converter = converter
    end

    def process(name, cell)
      dev_id = @converter.sanitized_id(name)
      
      width = cell['parameters']['WIDTH'].to_i
      s_width = cell['parameters']['S_WIDTH'].to_i
      
      args = {
        'type' => 'Mux1Hot',
        'label' => name,
        'bits' => {
          'in' => width,
          'sel' => s_width
        }
      }
      
      @converter.devices[dev_id] = args
      
      connect_bus(cell['connections']['A'], dev_id, 'in0', width)
      
      if s_width > 0
        s_nets = cell['connections']['S']
        reversed_s = s_nets.reverse
        reversed_s.each_with_index do |net, i|
           @converter.connect_net(net, dev_id, 'sel', i)
        end
      end
      
      connect_bus(cell['connections']['Y'], dev_id, 'out', width)
      
      b_nets = cell['connections']['B']
      
      s_width.times do |i|
        p_index = (s_width - i - 1) * width
        chunk = b_nets[p_index, width]
        
        chunk.each_with_index do |net, bit|
          @converter.connect_net(net, dev_id, "in#{i+1}", bit)
        end
      end
    end

    private

    def connect_bus(nets, dev_id, port, length)
      nets.each_with_index do |net, i|
        next if i >= length
        @converter.connect_net(net, dev_id, port, i)
      end
    end
  end
end
