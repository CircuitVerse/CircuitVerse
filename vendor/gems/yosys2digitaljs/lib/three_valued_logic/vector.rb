module ThreeValuedLogic
  class Vector
    attr_reader :bits, :avec, :bvec

    # Private initialization. Use factory methods instead.
    def initialize(bits, avec, bvec)
      @bits = bits
      @avec = avec
      @bvec = bvec
    end
    private_class_method :new

    # Factory methods
    def self.make(bits, init)
      case init
      when true, '1', 1
        new(bits, ~0, ~0)
      when false, '0', -1, 0, nil
        new(bits, 0, 0)
      when 'x'
        new(bits, 0, ~0)
      else
        raise ArgumentError, "Invalid initializer: #{init}"
      end
    end

    def self.zeros(bits)
      new(bits, 0, 0)
    end

    def self.ones(bits)
      new(bits, ~0, ~0)
    end

    def self.xes(bits)
      new(bits, 0, ~0)
    end

    # --- Parsing Methods ---

    # Parse Verilog-style strings: "32'b101x", "4'hF", "10" (decimal)
    def self.from_string(str)
      return from_bin(str) if str.match?(/^[01x]+$/i)

      match = str.match(/^(\d+)?'?(b|h|d|o)([0-9a-fA-FxXzZ_?]+)$/)
      raise ArgumentError, "Invalid Verilog string: #{str}" unless match

      size = match[1]&.to_i
      base = match[2].downcase
      value = match[3].gsub('_', '')

      case base
      when 'b' then from_bin(value, size)
      when 'h' then from_hex(value, size)
      when 'o' then from_oct(value, size)
      when 'd' then from_decimal(value, size)
      end
    end

    def self.from_bin(str, size = nil)
      size ||= str.length
      avec = 0
      bvec = 0
      
      str.chars.reverse.each_with_index do |char, i|
        next if i >= size
        
        case char.downcase
        when '1'
          avec |= (1 << i)
          bvec |= (1 << i)
        when '0'
          # default is 0
        when 'x', 'z', '?'
          # undefined
          bvec |= (1 << i)
        end
      end

      new(size, avec, bvec)
    end

    def self.from_hex(str, size = nil)
      size ||= str.length * 4
      bin_str = str.chars.map do |c|
        case c.downcase
        when 'x', 'z', '?' then 'xxxx'
        else c.hex.to_s(2).rjust(4, '0')
        end
      end.join
      
      # Hex string expansion might be too long, slice from right
      if bin_str.length > size
        bin_str = bin_str[-size..-1] 
      end

      from_bin(bin_str, size)
    end

    def self.from_oct(str, size = nil)
      size ||= str.length * 3
      bin_str = str.chars.map do |c|
        case c.downcase
        when 'x', 'z', '?' then 'xxx'
        else c.to_i(8).to_s(2).rjust(3, '0')
        end
      end.join
      
      if bin_str.length > size
        bin_str = bin_str[-size..-1] 
      end

      from_bin(bin_str, size)
    end

    def self.from_decimal(str, size = nil)
      # Decimal doesn't support 'x'.
      val = str.to_i
      # size default?
      size ||= [val.bit_length, 1].max
      
      # 1s everywhere
      mask = (1 << size) - 1
      # a=val, b=val (because no x's)
      new(size, val & mask, val & mask)
    end

    # --- Bitwise Operations ---
    # In TS: a & b
    # In Ruby, Integers are infinite, so this works perfectly.

    def &(other)
      check_size!(other)
      Vector.new(@bits, @avec & other.avec, @bvec & other.bvec)
    end

    def |(other)
      check_size!(other)
      Vector.new(@bits, @avec | other.avec, @bvec | other.bvec)
    end

    def ^(other)
      check_size!(other)

      a1 = other.avec
      a2 = other.bvec
      b1 = @avec
      b2 = @bvec
      
      new_avec = (a1 | b1) & (a2 ^ b2)
      new_bvec = (a1 & b1) ^ (a2 | b2)

      Vector.new(@bits, new_avec, new_bvec)
    end

    def ~
      mask = (1 << @bits) - 1
      Vector.new(@bits, ~@bvec & mask, ~@avec & mask)
    end

    # --- Reductions ---
    # Output is always 1-bit Vector
    
    # & reduction: 1 if all bits are 1. 0 if any bit is 0. x otherwise.
    def reduce_and
      mask = (1 << @bits) - 1
      # Check for 0s: Is there any position where A=0, B=0?
      # (a | b) should be 1s everywhere.
      # If (~(a | b) & mask) != 0, we have a 0.
      if (~(@avec | @bvec) & mask) != 0
        return Vector.make(1, 0)
      end
      
      # No 0s. Are there x's?
      # If a != b, we have x.
      # (a ^ b) & mask != 0
      if ((@avec ^ @bvec) & mask) != 0
        return Vector.make(1, 'x')
      end

      # Must be all 1s
      Vector.make(1, 1)
    end

    def reduce_or
      mask = (1 << @bits) - 1
      # Check for 1s: Any position (1,1)?
      # a & b != 0
      if ((@avec & @bvec) & mask) != 0
        return Vector.make(1, 1)
      end

      # No 1s. Any x's?
      if ((@avec ^ @bvec) & mask) != 0
        return Vector.make(1, 'x')
      end

      # All 0s
      Vector.make(1, 0)
    end

    def reduce_xor
      # Parity check.
      # If there is any x, the result is x.
      mask = (1 << @bits) - 1
      if ((@avec ^ @bvec) & mask) != 0
        return Vector.make(1, 'x')
      end
      
      # No x's. Just standard XOR reduction on bits.
      # Ruby Integer doesn't have parity method?
      # Hacky parity: count 1s.
      count = (@avec & mask).to_s(2).count('1')
      Vector.make(1, count.odd? ? 1 : 0)
    end

    # --- Inspection ---
    def to_s
      # Convert to string (MSB first)
      (0...@bits).map { |i| get(i) }.reverse.join
    end

    def get(n)
      # Returns string '0', '1', 'x'
      return '0' if n >= @bits
      
      a = (@avec >> n) & 1
      b = (@bvec >> n) & 1
      
      case [a, b]
      when [0, 0] then '0'
      when [1, 1] then '1'
      else 'x'
      end
    end

    private

    def check_size!(other)
      raise ArgumentError, "Vector size mismatch: #{@bits} vs #{other.bits}" unless @bits == other.bits
    end
  end
end
