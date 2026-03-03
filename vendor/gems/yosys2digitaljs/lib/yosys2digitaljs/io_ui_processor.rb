module Yosys2Digitaljs
  class IoUiProcessor
    def self.process(devices)
      devices.each do |id, dev|
        type = dev['type']
        next unless ['Input', 'Output'].include?(type)

        label = dev['label'] || dev['net']
        bits = dev['bits'].is_a?(Hash) ? dev['bits']['out'] || dev['bits']['in'] : dev['bits']
        bits = bits.to_i 

        if type == 'Input' || type == 'Output'
            dev['label'] = dev['net'] if dev['label'].nil? || dev['label'].empty?
        end
      end
    end
  end
end
