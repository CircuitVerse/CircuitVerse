module Yosys2Digitaljs
  class FsmProcessor
    def initialize(converter)
      @converter = converter
    end

    def process(name, cell)
      width = cell['parameters']['WIDTH'].to_i
      ctrl_in_width = cell['parameters']['CTRL_IN_WIDTH'].to_i
      ctrl_out_width = cell['parameters']['CTRL_OUT_WIDTH'].to_i
      trans_num = cell['parameters']['TRANS_NUM'].to_i
      state_num_log2 = cell['parameters']['STATE_NUM_LOG2'].to_i
      state_num = cell['parameters']['STATE_NUM'].to_i
      state_rst = cell['parameters']['STATE_RST'].to_i
      trans_table_raw = cell['parameters']['TRANS_TABLE']

      step_size = 2 * state_num_log2 + ctrl_in_width + ctrl_out_width

      full_len = trans_num * step_size
      binary_table = if trans_table_raw.is_a?(Integer)
                       # It's a number, convert to binary
                       trans_table_raw.to_s(2).rjust(full_len, '0')
                     else
                       # It's a bit string (01xz...) - use as is (with padding)
                       trans_table_raw.to_s.rjust(full_len, '0')
                     end
      
      trans_table = []
      
      # Iterate through transitions
      
      current_idx = 0
      trans_num.times do
        state_in_bits = binary_table[current_idx, state_num_log2] || "0" * state_num_log2
        current_idx += state_num_log2
        
        ctrl_in_bits = binary_table[current_idx, ctrl_in_width] || "0" * ctrl_in_width
        current_idx += ctrl_in_width
        
        state_out_bits = binary_table[current_idx, state_num_log2] || "0" * state_num_log2
        current_idx += state_num_log2
        
        ctrl_out_bits = binary_table[current_idx, ctrl_out_width] || "0" * ctrl_out_width
        current_idx += ctrl_out_width

        trans_table << {
          'state_in' => state_in_bits.to_i(2),
          'ctrl_in' => ctrl_in_bits.gsub('-', 'x'), # Replace don't cares
          'state_out' => state_out_bits.to_i(2),
          'ctrl_out' => ctrl_out_bits
        }
      end

      dev_id = @converter.sanitized_id(name)
      
      args = {
        'type' => 'FSM',
        'label' => cell['attributes']['src'] || name, # Use source name if avail
        'wirename' => cell['parameters']['NAME'],
        'bits' => {
          'in' => ctrl_in_width,
          'out' => ctrl_out_width
        },
        'states' => state_num,
        'init_state' => state_rst,
        'trans_table' => trans_table,
        'polarity' => {
          'clock' => cell['parameters']['CLK_POLARITY'].to_i == 1,
          'arst' => cell['parameters']['ARST_POLARITY'].to_i == 1
        }
      }

      @converter.devices[dev_id] = args

      if cell['connections']['CLK'] && !cell['connections']['CLK'].empty?
        @converter.connect_net(cell['connections']['CLK'][0], dev_id, 'clk', 0)
      end

      if cell['connections']['ARST'] && !cell['connections']['ARST'].empty?
        @converter.connect_net(cell['connections']['ARST'][0], dev_id, 'arst', 0)
      end

      Array(cell['connections']['CTRL_IN']).each_with_index do |net, i|
        @converter.connect_net(net, dev_id, 'in', i)
      end

      Array(cell['connections']['CTRL_OUT']).each_with_index do |net, i|
        @converter.connect_net(net, dev_id, 'out', i)
      end
    end
  end
end
