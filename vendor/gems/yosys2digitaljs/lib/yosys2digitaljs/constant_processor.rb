module Yosys2Digitaljs
  class ConstantProcessor
    def initialize(converter)
      @converter = converter
    end

    def process
      grouped_cons = Hash.new { |h, k| h[k] = [] }
      
      return unless @converter.constants
      
      @converter.constants.each do |val, usages|
        usages.each do |usage|
          key = [usage[:id], usage[:port]]
          grouped_cons[key] << { val: val, bit: usage[:bit] }
        end
      end
      
      grouped_cons.each do |(dev_id, port), bits|
        bits.sort_by! { |b| b[:bit] }
        
        chunk = []
        last_bit = -1
        
        bits.each do |b|
           if last_bit != -1 && b[:bit] != last_bit + 1
              create_constant(dev_id, port, chunk)
              chunk = []
           end
           chunk << b
           last_bit = b[:bit]
        end
        create_constant(dev_id, port, chunk) unless chunk.empty?
      end
    end
    
    def create_constant(target_dev_id, target_port, chunk)
       val_string = chunk.map { |x| x[:val] }.join('').reverse
       
       const_val = chunk.map { |x| x[:val] }.join('').reverse
       
       dev_id = @converter.send(:sanitized_id, "const_#{target_dev_id}_#{target_port}_#{chunk.first[:bit]}")
       
       @converter.devices[dev_id] = {
         'type' => 'Constant',
         'constant' => const_val,
         'label' => const_val,
         'bits' => const_val.length
       }
       
       # Connect
       conn = {
         'from' => { 'id' => dev_id, 'port' => 'out' },
         'to' => { 'id' => target_dev_id, 'port' => target_port },
         'name' => const_val
       }
       @converter.connectors << conn
       
    end
  end
end
