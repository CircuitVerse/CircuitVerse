require "msgpack/version"

if defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby" # This is same with `/java/ =~ RUBY_VERSION`
  require "msgpack/msgpack.jar"
  JRuby::Util.load_ext("org.msgpack.jruby.MessagePackLibrary")
else
  require "msgpack/msgpack"
end

require "msgpack/packer"
require "msgpack/unpacker"
require "msgpack/factory"
require "msgpack/symbol"
require "msgpack/core_ext"
require "msgpack/timestamp"
require "msgpack/time"

module MessagePack
  DefaultFactory = MessagePack::Factory.new

  def load(src, param = nil)
    unpacker = nil

    if src.is_a? String
      unpacker = DefaultFactory.unpacker param
      unpacker.feed_reference src
    else
      unpacker = DefaultFactory.unpacker src, param
    end

    unpacker.full_unpack
  end
  alias :unpack :load

  module_function :load
  module_function :unpack

  def pack(v, io = nil, options = nil)
    packer = DefaultFactory.packer(io, options)
    packer.write v
    packer.full_pack
  end
  alias :dump :pack

  module_function :pack
  module_function :dump
end
