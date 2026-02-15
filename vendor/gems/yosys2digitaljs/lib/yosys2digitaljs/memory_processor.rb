module Yosys2Digitaljs
  class MemoryProcessor
    def initialize(converter)
      @converter = converter
    end

    def process(name, cell)
      params = cell['parameters']
      rd_ports = decode_param(params['RD_PORTS'])
      wr_ports = decode_param(params['WR_PORTS'])
      width    = decode_param(params['WIDTH'])
      abits    = decode_param(params['ABITS'])
      size     = decode_param(params['SIZE'])
      offset   = decode_param(params['OFFSET'])

      dev_id = @converter.send(:sanitized_id, name)
      dev = {
        'type' => 'Memory',
        'label' => name,
        'bits' => width,
        'abits' => abits,
        'words' => size,
        'offset' => offset,
        'rdports' => [],
        'wrports' => []
      }

      if params['INIT']
        init_str = params['INIT']
        dev['INIT'] = init_str if init_str
      end

      rd_clk_enable = decode_bits(params['RD_CLK_ENABLE'], rd_ports).reverse
      rd_clk_polarity = decode_bits(params['RD_CLK_POLARITY'], rd_ports).reverse
      rd_transparent = decode_bits(params['RD_TRANSPARENT'], rd_ports).reverse
      
      rd_ports.times do |k|
        port = {}
        if rd_clk_enable[k] == 1
          port['clock_polarity'] = (rd_clk_polarity[k] == 1)
        end
        port['transparent'] = true if rd_transparent[k] == 1
        dev['rdports'] << port
        
        base_addr = k * abits
        base_data = k * width
        
        connect_bus(cell['connections']['RD_ADDR'], base_addr, abits, dev_id, "rd#{k}addr", 'in')
        connect_bus(cell['connections']['RD_DATA'], base_data, width, dev_id, "rd#{k}data", 'out')
        
        connect_bit(cell['connections']['RD_CLK'], k, dev_id, "rd#{k}clk") if port['clock_polarity']
      end

      wr_clk_enable = decode_bits(params['WR_CLK_ENABLE'], wr_ports).reverse
      wr_clk_polarity = decode_bits(params['WR_CLK_POLARITY'], wr_ports).reverse
      
      wr_ports.times do |k|
        port = {}
        if wr_clk_enable[k] == 1
           port['clock_polarity'] = (wr_clk_polarity[k] == 1)
        end
        dev['wrports'] << port
        
        base_addr = k * abits
        base_data = k * width
        
        connect_bus(cell['connections']['WR_ADDR'], base_addr, abits, dev_id, "wr#{k}addr", 'in')
        connect_bus(cell['connections']['WR_DATA'], base_data, width, dev_id, "wr#{k}data", 'in')
        
        connect_bit(cell['connections']['WR_CLK'], k, dev_id, "wr#{k}clk") if port['clock_polarity']
        connect_bus(cell['connections']['WR_EN'], base_data, width, dev_id, "wr#{k}en", 'in')
      end

      @converter.instance_variable_get(:@devices)[dev_id] = dev
    end

    private

    def decode_param(val)
      return 0 if val.nil?
      return val if val.is_a?(Integer)
      return val.to_i(2) if val.is_a?(String)
      0
    end

    def decode_bits(val, size)
      int_val = decode_param(val)
      int_val.to_s(2).rjust(size, '0').chars.map(&:to_i)
    end

    def connect_bus(nets, start_idx, length, dev_id, port_name, dir)
      slice = nets[start_idx, length]
      djs_port = (dir == 'input' || dir == 'in') ? 'in' : 'out' 

      slice.each_with_index do |net_id, i|
         @converter.connect_net(net_id, dev_id, port_name, i)
      end
    end
    
    def connect_bit(nets, idx, dev_id, port_name)
      net_id = nets[idx]
      @converter.connect_net(net_id, dev_id, port_name, 0)
    end
  end
end
