
if ENV['SIMPLE_COV']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec/'
    add_filter 'pkg/'
    add_filter 'vendor/'
  end
end

if ENV['GC_STRESS']
  puts "enable GC.stress"
  GC.stress = true
end

require 'msgpack'

def java?
  /java/ =~ RUBY_PLATFORM
end

# checking if Hash#[]= (rb_hash_aset) dedupes string keys
def automatic_string_keys_deduplication?
  h = {}
  x = {}
  r = rand.to_s
  h[%W(#{r}).join('')] = :foo
  x[%W(#{r}).join('')] = :foo

  x.keys[0].equal?(h.keys[0])
end

def string_deduplication?
  r1 = rand.to_s
  r2 = r1.dup
  (-r1).equal?(-r2)
end

if java?
  RSpec.configure do |c|
    c.treat_symbols_as_metadata_keys_with_true_values = true
    c.filter_run_excluding :encodings => !(defined? Encoding)
  end
else
  RSpec.configure do |config|
    config.expect_with :rspec do |c|
      c.syntax = [:should, :expect]
    end
  end
  Packer = MessagePack::Packer
  Unpacker = MessagePack::Unpacker
  Buffer = MessagePack::Buffer
  Factory = MessagePack::Factory
  ExtensionValue = MessagePack::ExtensionValue
end
