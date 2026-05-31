require 'rspec'
require_relative '../lib/three_valued_logic'

RSpec.describe ThreeValuedLogic::Vector do
  describe '.from_string' do
    it 'parses binary strings' do
      v = described_class.from_string("4'b10x0")
      expect(v.bits).to eq(4)
      expect(v.to_s).to eq("10x0")
    end

    it 'parses hex strings' do
      v = described_class.from_string("8'hF0")
      expect(v.to_s).to eq("11110000")
    end
    
    it 'handles implicit binary' do
      v = described_class.from_string("101")
      expect(v.to_s).to eq("101")
    end
  end

  describe 'Bitwise Operations' do
    let(:v1) { described_class.from_string("1010") } # 10, 2
    let(:v2) { described_class.from_string("1100") } # 12, 4
    let(:vx) { described_class.from_string("xxxx") }

    it 'ANDs correctly' do
      # 1010 & 1100 = 1000
      expect((v1 & v2).to_s).to eq("1000")
    end

    it 'ORs correctly' do
      # 1010 | 1100 = 1110
      expect((v1 | v2).to_s).to eq("1110")
    end
    
    it 'XORs correctly' do
      # 1010 ^ 1100 = 0110
      expect((v1 ^ v2).to_s).to eq("0110")
    end
    
    it 'NOTs correctly' do
      # ~1010 = 0101
      expect((~v1).to_s).to eq("0101")
    end

    it 'handles X in logic' do
      # 1 & x = x
      # 0 & x = 0
      a = described_class.from_string("10")
      b = described_class.from_string("xx")
      expect((a & b).to_s).to eq("x0")
    end
  end

  describe 'Reductions' do
    it 'reduce_and' do
      expect(described_class.from_string("111").reduce_and.to_s).to eq("1")
      expect(described_class.from_string("101").reduce_and.to_s).to eq("0")
      expect(described_class.from_string("1x1").reduce_and.to_s).to eq("x")
    end
    
    it 'reduce_or' do
      expect(described_class.from_string("000").reduce_or.to_s).to eq("0")
      expect(described_class.from_string("010").reduce_or.to_s).to eq("1")
      expect(described_class.from_string("0x0").reduce_or.to_s).to eq("x")
    end
  end
end
