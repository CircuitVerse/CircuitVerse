# % bundle install
# % bundle exec ruby bench/bench.rb

require 'msgpack'

require 'benchmark/ips'

object_plain = {
  'message' => '127.0.0.1 - - [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"'
}

data_plain = MessagePack.pack(object_plain)

object_structured = {
  'remote_host' => '127.0.0.1',
  'remote_user' => '-',
  'date' => '10/Oct/2000:13:55:36 -0700',
  'request' => 'GET /apache_pb.gif HTTP/1.0',
  'method' => 'GET',
  'path' => '/apache_pb.gif',
  'protocol' => 'HTTP/1.0',
  'status' => 200,
  'bytes' => 2326,
  'referer' => 'http://www.example.com/start.html',
  'agent' => 'Mozilla/4.08 [en] (Win98; I ;Nav)',
}

data_structured = MessagePack.pack(object_structured)

class Extended
  def to_msgpack_ext
    MessagePack.pack({})
  end

  def self.from_msgpack_ext(data)
    MessagePack.unpack(data)
    Extended.new
  end
end

object_extended = {
  'extended' => Extended.new
}

extended_packer = MessagePack::Packer.new
extended_packer.register_type(0x00, Extended, :to_msgpack_ext)
data_extended = extended_packer.pack(object_extended).to_s

Benchmark.ips do |x|
  x.report('pack-plain') do
    MessagePack.pack(object_plain)
  end

  x.report('pack-structured') do
    MessagePack.pack(object_structured)
  end

  x.report('pack-extended') do
    packer = MessagePack::Packer.new
    packer.register_type(0x00, Extended, :to_msgpack_ext)
    packer.pack(object_extended).to_s
  end

  x.report('unpack-plain') do
    MessagePack.unpack(data_plain)
  end

  x.report('unpack-structured') do
    MessagePack.unpack(data_structured)
  end

  x.report('unpack-extended') do
    unpacker = MessagePack::Unpacker.new
    unpacker.register_type(0x00, Extended, :from_msgpack_ext)
    unpacker.feed data_extended
    unpacker.read
  end
end
