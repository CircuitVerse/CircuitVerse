require 'spec_helper'

describe MessagePack::Factory do
  subject do
    described_class.new
  end

  describe '#packer' do
    it 'creates a Packer instance' do
      subject.packer.should be_kind_of(MessagePack::Packer)
    end

    it 'creates new instance' do
      subject.packer.object_id.should_not == subject.packer.object_id
    end
  end

  describe '#unpacker' do
    it 'creates a Unpacker instance' do
      subject.unpacker.should be_kind_of(MessagePack::Unpacker)
    end

    it 'creates new instance' do
      subject.unpacker.object_id.should_not == subject.unpacker.object_id
    end

    it 'creates unpacker with symbolize_keys option' do
      unpacker = subject.unpacker(symbolize_keys: true)
      unpacker.feed(MessagePack.pack({'k'=>'v'}))
      unpacker.read.should == {:k => 'v'}
    end

    it 'creates unpacker with allow_unknown_ext option' do
      unpacker = subject.unpacker(allow_unknown_ext: true)
      unpacker.feed(MessagePack::ExtensionValue.new(1, 'a').to_msgpack)
      unpacker.read.should == MessagePack::ExtensionValue.new(1, 'a')
    end

    it 'creates unpacker without allow_unknown_ext option' do
      unpacker = subject.unpacker
      unpacker.feed(MessagePack::ExtensionValue.new(1, 'a').to_msgpack)
      expect{ unpacker.read }.to raise_error(MessagePack::UnknownExtTypeError)
    end

    it 'does not share the extension registry with unpackers' do
      subject.register_type(0x00, Symbol)
      expect do
        unpacker = subject.unpacker
        expect do
          unpacker.register_type(0x01) {}
        end.to change { unpacker.registered_types }

        second_unpacker = subject.unpacker
        expect do
          second_unpacker.register_type(0x01) {}
        end.to_not change { unpacker.registered_types }
      end.to_not change { subject.registered_types }
    end
  end

  describe '#dump and #load' do
    it 'can be used like a standard coder' do
      subject.register_type(0x00, Symbol)
      expect(subject.load(subject.dump(:symbol))).to be == :symbol
    end

    it 'is alias as pack and unpack' do
      subject.register_type(0x00, Symbol)
      expect(subject.unpack(subject.pack(:symbol))).to be == :symbol
    end

    it 'accept options' do
      hash = subject.unpack(MessagePack.pack('k' => 'v'), symbolize_keys: true)
      expect(hash).to be == { k: 'v' }
    end
  end

  describe '#freeze' do
    it 'can freeze factory instance to deny new registrations anymore' do
      subject.register_type(0x00, Symbol)
      subject.freeze
      expect(subject.frozen?).to be_truthy
      expect{ subject.register_type(0x01, Array) }.to raise_error(RuntimeError, "can't modify frozen Factory")
    end
  end

  class MyType
    def initialize(a, b)
      @a = a
      @b = b
    end

    attr_reader :a, :b

    def to_msgpack_ext
      [a, b].pack('CC')
    end

    def self.from_msgpack_ext(data)
      new(*data.unpack('CC'))
    end

    def to_msgpack_ext_only_a
      [a, 0].pack('CC')
    end

    def self.from_msgpack_ext_only_b(data)
      a, b = *data.unpack('CC')
      new(0, b)
    end
  end

  class MyType2 < MyType
  end

  describe '#registered_types' do
    it 'returns Array' do
      expect(subject.registered_types).to be_instance_of(Array)
    end

    it 'returns Array of Hash contains :type, :class, :packer, :unpacker' do
      subject.register_type(0x20, ::MyType)
      subject.register_type(0x21, ::MyType2)

      list = subject.registered_types

      expect(list.size).to eq(2)
      expect(list[0]).to be_instance_of(Hash)
      expect(list[1]).to be_instance_of(Hash)
      expect(list[0].keys.sort).to eq([:type, :class, :packer, :unpacker].sort)
      expect(list[1].keys.sort).to eq([:type, :class, :packer, :unpacker].sort)

      expect(list[0][:type]).to eq(0x20)
      expect(list[0][:class]).to eq(::MyType)
      expect(list[0][:packer]).to eq(:to_msgpack_ext)
      expect(list[0][:unpacker]).to eq(:from_msgpack_ext)

      expect(list[1][:type]).to eq(0x21)
      expect(list[1][:class]).to eq(::MyType2)
      expect(list[1][:packer]).to eq(:to_msgpack_ext)
      expect(list[1][:unpacker]).to eq(:from_msgpack_ext)
    end

    it 'returns Array of Hash which has nil for unregistered feature' do
      subject.register_type(0x21, ::MyType2, unpacker: :from_msgpack_ext)
      subject.register_type(0x20, ::MyType, packer: :to_msgpack_ext)

      list = subject.registered_types

      expect(list.size).to eq(2)
      expect(list[0]).to be_instance_of(Hash)
      expect(list[1]).to be_instance_of(Hash)
      expect(list[0].keys.sort).to eq([:type, :class, :packer, :unpacker].sort)
      expect(list[1].keys.sort).to eq([:type, :class, :packer, :unpacker].sort)

      expect(list[0][:type]).to eq(0x20)
      expect(list[0][:class]).to eq(::MyType)
      expect(list[0][:packer]).to eq(:to_msgpack_ext)
      expect(list[0][:unpacker]).to be_nil

      expect(list[1][:type]).to eq(0x21)
      expect(list[1][:class]).to eq(::MyType2)
      expect(list[1][:packer]).to be_nil
      expect(list[1][:unpacker]).to eq(:from_msgpack_ext)
    end
  end

  describe '#type_registered?' do
    it 'receive Class or Integer, and return bool' do
      expect(subject.type_registered?(0x00)).to be_falsy
      expect(subject.type_registered?(0x01)).to be_falsy
      expect(subject.type_registered?(::MyType)).to be_falsy
    end

    it 'has option to specify what types are registered for' do
      expect(subject.type_registered?(0x00, :both)).to be_falsy
      expect(subject.type_registered?(0x00, :packer)).to be_falsy
      expect(subject.type_registered?(0x00, :unpacker)).to be_falsy
      expect{ subject.type_registered?(0x00, :something) }.to raise_error(ArgumentError)
    end

    it 'returns true if specified type or class is already registered' do
      subject.register_type(0x20, ::MyType)
      subject.register_type(0x21, ::MyType2)

      expect(subject.type_registered?(0x00)).to be_falsy
      expect(subject.type_registered?(0x01)).to be_falsy

      expect(subject.type_registered?(0x20)).to be_truthy
      expect(subject.type_registered?(0x21)).to be_truthy
      expect(subject.type_registered?(::MyType)).to be_truthy
      expect(subject.type_registered?(::MyType2)).to be_truthy
    end
  end

  describe '#register_type' do
    let :src do
      ::MyType.new(1, 2)
    end

    it 'registers #to_msgpack_ext and .from_msgpack_ext by default' do
      subject.register_type(0x7f, ::MyType)

      data = subject.packer.write(src).to_s
      my = subject.unpacker.feed(data).read
      my.a.should == 1
      my.b.should == 2
    end

    it 'registers custom packer method name' do
      subject.register_type(0x7f, ::MyType, packer: :to_msgpack_ext_only_a, unpacker: :from_msgpack_ext)

      data = subject.packer.write(src).to_s
      my = subject.unpacker.feed(data).read
      my.a.should == 1
      my.b.should == 0
    end

    it 'registers custom unpacker method name' do
      subject.register_type(0x7f, ::MyType, packer: :to_msgpack_ext, unpacker: 'from_msgpack_ext_only_b')

      data = subject.packer.write(src).to_s
      my = subject.unpacker.feed(data).read
      my.a.should == 0
      my.b.should == 2
    end

    it 'registers custom proc objects' do
      pk = lambda {|obj| [obj.a + obj.b].pack('C') }
      uk = lambda {|data| ::MyType.new(data.unpack('C').first, -1) }
      subject.register_type(0x7f, ::MyType, packer: pk, unpacker: uk)

      data = subject.packer.write(src).to_s
      my = subject.unpacker.feed(data).read
      my.a.should == 3
      my.b.should == -1
    end

    it 'does not affect existent packer and unpackers' do
      subject.register_type(0x7f, ::MyType)
      packer = subject.packer
      unpacker = subject.unpacker

      subject.register_type(0x7f, ::MyType, packer: :to_msgpack_ext_only_a, unpacker: :from_msgpack_ext_only_b)

      data = packer.write(src).to_s
      my = unpacker.feed(data).read
      my.a.should == 1
      my.b.should == 2
    end

    describe "registering an ext type for a module" do
      before do
        mod = Module.new do
          def self.from_msgpack_ext(data)
            "unpacked #{data}"
          end

          def to_msgpack_ext
            'value_msgpacked'
          end
        end
        stub_const('Mod', mod)
      end
      let(:factory) { described_class.new }
      before { factory.register_type(0x01, Mod) }

      describe "packing an object whose class included the module" do
        subject { factory.packer.pack(value).to_s }
        before { stub_const('Value', Class.new{ include Mod }) }
        let(:value) { Value.new }
        it { is_expected.to eq "\xC7\x0F\x01value_msgpacked".force_encoding(Encoding::BINARY) }
      end

      describe "packing an object which has been extended by the module" do
        subject { factory.packer.pack(object).to_s }
        let(:object) { Object.new.extend Mod }
        it { is_expected.to eq "\xC7\x0F\x01value_msgpacked".force_encoding(Encoding::BINARY) }
      end

      describe "unpacking with the module" do
        subject { factory.unpacker.feed("\xC7\x06\x01module".force_encoding(Encoding::BINARY)).unpack }
        it { is_expected.to eq "unpacked module" }
      end
    end

    describe "registering an ext type for Integer" do
      let(:factory) { described_class.new }
      let(:bigint) { 10**150 }

      it 'does not work by default without passing `oversized_integer_extension: true`' do
        factory.register_type(0x01, Integer, packer: :to_s, unpacker: method(:Integer))

        expect do
          factory.dump(bigint)
        end.to raise_error RangeError
      end

      it 'raises ArgumentError if the type is not Integer' do
        expect do
          factory.register_type(0x01, MyType, packer: :to_s, unpacker: method(:Integer), oversized_integer_extension: true)
        end.to raise_error(ArgumentError)
      end

      it 'invokes the packer if registered with `oversized_integer_extension: true`' do
        factory.register_type(0x01, Integer, packer: :to_s, unpacker: method(:Integer), oversized_integer_extension: true)

        expect(factory.load(factory.dump(bigint))).to be == bigint
      end

      it 'does not use the oversized_integer_extension packer for integers fitting in native types' do
        factory.register_type(
          0x01,
          Integer,
          packer: ->(int) { raise NotImplementedError },
          unpacker: ->(payload) { raise NotImplementedError },
          oversized_integer_extension: true
        )

        expect(factory.dump(42)).to eq(MessagePack.dump(42))
      end
    end

    describe "registering ext type with recursive serialization" do
      before do
        stub_const("Point", Struct.new(:x, :y, :z))
      end

      it 'can receive the packer as argument (proc)' do
        factory = MessagePack::Factory.new
        factory.register_type(0x00, Symbol)
        factory.register_type(
          0x01,
          Point,
          packer: ->(point, packer) do
            packer.write(point.to_h)
            nil
          end,
          unpacker: ->(unpacker) do
            attrs = unpacker.read
            Point.new(attrs.fetch(:x), attrs.fetch(:y), attrs.fetch(:z))
          end,
          recursive: true,
        )

        point = Point.new(1, 2, 3)
        payload = factory.dump(point)
        expect(factory.load(payload)).to be == point
      end

      it 'can receive the packer as argument (Method)' do
        mod = Module.new
        mod.define_singleton_method(:packer) do |point, packer|
          packer.write(point.to_h)
          nil
        end

        mod.define_singleton_method(:unpacker) do |unpacker|
          attrs = unpacker.read
          Point.new(attrs.fetch(:x), attrs.fetch(:y), attrs.fetch(:z))
        end

        factory = MessagePack::Factory.new
        factory.register_type(0x00, Symbol)
        factory.register_type(
          0x01,
          Point,
          packer: mod.method(:packer),
          unpacker: mod.method(:unpacker),
          recursive: true,
        )

        point = Point.new(1, 2, 3)
        payload = factory.dump(point)
        expect(factory.load(payload)).to be == point
      end

      it 'respect message pack format' do
        factory = MessagePack::Factory.new
        factory.register_type(0x00, Symbol)
        factory.register_type(
          0x01,
          Point,
          packer: ->(point, packer) do
            packer.write(point.to_a)
            nil
          end,
          unpacker: ->(unpacker) do
            attrs = unpacker.read
            Point.new(*attrs)
          end,
          recursive: true,
        )

        point = Point.new(1, 2, 3)
        expect(factory.dump(point)).to be == "\xD6\x01".b + MessagePack.dump([1, 2, 3])
      end

      it 'sets the correct length' do
        factory = MessagePack::Factory.new
        factory.register_type(0x00, Symbol)
        factory.register_type(
          0x01,
          Point,
          packer: ->(point, packer) do
            packer.write(point.to_h)
            nil
          end,
          unpacker: ->(unpacker) do
            attrs = unpacker.read
            Point.new(attrs.fetch(:x), attrs.fetch(:y), attrs.fetch(:z))
          end,
          recursive: true,
        )

        point = Point.new(1, 2, 3)
        payload = factory.dump([1, point, 3])

        obj = MessagePack::Factory.new.load(payload, allow_unknown_ext: true)
        expect(obj).to be == [
          1,
          MessagePack::ExtensionValue.new(1, factory.dump(x: 1, y: 2, z: 3)),
          3,
        ]

        expect(factory.load(payload)).to be == [
          1,
          Point.new(1, 2, 3),
          3,
        ]
      end

      it 'can be nested' do
        factory = MessagePack::Factory.new
        factory.register_type(
          0x02,
          Set,
          packer: ->(set, packer) do
            packer.write(set.to_a)
            nil
          end,
          unpacker: ->(unpacker) do
            unpacker.read.to_set
          end,
          recursive: true,
        )

        expected = Set[1, Set[2, Set[3]]]
        payload = factory.dump(expected)
        expect(payload).to be == "\xC7\v\x02\x92\x01\xC7\x06\x02\x92\x02\xD5\x02\x91\x03".b
        expect(factory.load(factory.dump(expected))).to be == expected
      end
    end
  end

  describe 'the special treatment of symbols with ext type' do
    def roundtrip(object, options = nil)
      subject.load(subject.dump(object), options)
    end

    context 'using the optimized symbol unpacker' do
      before do
        skip if IS_JRUBY # JRuby implementation doesn't support the optimized symbols unpacker for now
        subject.register_type(
          0x00,
          ::Symbol,
          packer: :to_msgpack_ext,
          unpacker: :from_msgpack_ext,
          optimized_symbols_parsing: true,
        )
      end

      it 'lets symbols survive a roundtrip' do
        expect(roundtrip(:symbol)).to be :symbol
      end

      it 'works with empty symbol' do
        expect(roundtrip(:"")).to be :""
      end

      it 'preserves encoding for ASCII symbols' do
        expect(:symbol.encoding).to be Encoding::US_ASCII
        expect(roundtrip(:symbol)).to be :symbol
        expect(roundtrip(:symbol).encoding).to be Encoding::US_ASCII
      end

      it 'preserves encoding for UTF-8 symbols' do
        expect(:"fée".encoding).to be Encoding::UTF_8
        expect(roundtrip(:"fée").encoding).to be Encoding::UTF_8
        expect(roundtrip(:"fée")).to be :"fée"
      end
    end

    context 'if no ext type is registered for symbols' do
      it 'converts symbols to string' do
        expect(roundtrip(:symbol)).to eq 'symbol'
      end
    end

    context 'if an ext type is registered for symbols' do
      context 'if using the default serializer' do
        before { subject.register_type(0x00, ::Symbol) }

        it 'lets symbols survive a roundtrip' do
          expect(roundtrip(:symbol)).to be :symbol
        end

        it 'works with hash keys' do
          expect(roundtrip(symbol: 1)).to be == { symbol: 1 }
        end

        it 'works with frozen: true option' do
          expect(roundtrip(:symbol, freeze: true)).to be :symbol
        end

        it 'preserves encoding for ASCII symbols' do
          expect(:symbol.encoding).to be Encoding::US_ASCII
          expect(roundtrip(:symbol)).to be :symbol
          expect(roundtrip(:symbol).encoding).to be Encoding::US_ASCII
        end

        it 'preserves encoding for UTF-8 symbols' do
          expect(:"fée".encoding).to be Encoding::UTF_8
          expect(roundtrip(:"fée")).to be :"fée"
          expect(roundtrip(:"fée").encoding).to be Encoding::UTF_8
        end

        it 'does not handle symbols in other encodings' do
          symbol = "fàe".encode(Encoding::ISO_8859_1).to_sym
          expect(symbol.encoding).to be Encoding::ISO_8859_1

          if IS_JRUBY
            # JRuby doesn't quite behave like MRI here.
            # "fàe".force_encoding(Encoding::BINARY).to_sym is able to lookup the existing ISO-8859-1 symbol
            # It likely is a JRuby bug.
            expect(roundtrip(symbol).encoding).to be Encoding::ISO_8859_1
          else
            expect(roundtrip(symbol).encoding).to be Encoding::BINARY
          end
        end
      end

      context 'if using a custom serializer' do
        before do
          class Symbol
            alias_method :to_msgpack_ext_orig, :to_msgpack_ext
            def to_msgpack_ext
              self.to_s.codepoints.to_a.pack('n*')
            end
          end

          class << Symbol
            alias_method :from_msgpack_ext_orig, :from_msgpack_ext
            def from_msgpack_ext(data)
              data.unpack('n*').map(&:chr).join.to_sym
            end
          end
        end

        before { subject.register_type(0x00, ::Symbol) }

        it 'lets symbols survive a roundtrip' do
          expect(roundtrip(:symbol)).to be :symbol
        end

        after do
          class Symbol
            alias_method :to_msgpack_ext, :to_msgpack_ext_orig
          end

          class << Symbol
            alias_method :from_msgpack_ext, :from_msgpack_ext_orig
          end
        end
      end
    end
  end

  describe 'under stressful GC' do
    it 'works well' do
      begin
        GC.stress = true

        f = MessagePack::Factory.new
        f.register_type(0x0a, Symbol)
      ensure
        GC.stress = false
      end
    end

    it 'does not crash in recursive extensions' do
      my_hash_type = Class.new(Hash)
      factory = MessagePack::Factory.new
      factory.register_type(7,
        my_hash_type,
        packer: ->(value, packer) do
          packer.write(value.to_h)
        end,
        unpacker: ->(unpacker) { my_hash_type.new(unpacker.read) },
        recursive: true,
      )

      payload = factory.dump(
        [my_hash_type.new]
      )

      begin
        GC.stress = true
        factory.load(payload)
      ensure
        GC.stress = false
      end
    end
  end

  describe 'memsize' do
    it 'works on a fresh factory' do
      skip "JRuby doesn't support ObjectSpace.memsize_of" if IS_JRUBY

      f = MessagePack::Factory.new
      expect(ObjectSpace.memsize_of(f)).to be_an(Integer)
    end

    it 'works on a factory with registered types' do
      skip "JRuby doesn't support ObjectSpace.memsize_of" if IS_JRUBY

      f = MessagePack::Factory.new
      base_size = ObjectSpace.memsize_of(f)
      f.register_type(0x0a, Symbol)
      expect(ObjectSpace.memsize_of(f)).to be > base_size
    end
  end

  describe 'DefaultFactory' do
    it 'is a factory' do
      MessagePack::DefaultFactory.should be_kind_of(MessagePack::Factory)
    end

    require_relative 'exttypes'

    it 'should be referred by MessagePack.pack and MessagePack.unpack' do
      MessagePack::DefaultFactory.register_type(DummyTimeStamp1::TYPE, DummyTimeStamp1)
      MessagePack::DefaultFactory.register_type(DummyTimeStamp2::TYPE, DummyTimeStamp2, packer: :serialize, unpacker: :deserialize)

      t = Time.now

      dm1 = DummyTimeStamp1.new(t.to_i, t.usec)
      expect(MessagePack.unpack(MessagePack.pack(dm1))).to eq(dm1)

      dm2 = DummyTimeStamp1.new(t.to_i, t.usec)
      expect(MessagePack.unpack(MessagePack.pack(dm2))).to eq(dm2)
    end
  end

  describe '#pool' do
    let(:factory) { described_class.new }

    it 'responds to serializers interface' do
      pool = factory.pool(1)
      expect(pool.load(pool.dump(42))).to be == 42
    end

    it 'types can be registered before the pool is created' do
      factory.register_type(0x00, Symbol)
      pool = factory.pool(1)
      expect(pool.load(pool.dump(:foo))).to be == :foo
    end

    it 'types cannot be registered after the pool is created' do
      pool = factory.pool(1)
      factory.register_type(0x20, ::MyType)

      expect do
        pool.dump(MyType.new(1, 2))
      end.to raise_error NoMethodError

      payload = factory.dump(MyType.new(1, 2))
      expect do
        pool.load(payload)
      end.to raise_error MessagePack::UnknownExtTypeError
    end

    it 'support symbolize_keys: true' do
      pool = factory.pool(1, symbolize_keys: true)
      expect(pool.load(pool.dump('foo' => 1))).to be == { foo: 1 }
    end

    it 'support freeze: true' do
      pool = factory.pool(1, freeze: true)
      expect(pool.load(pool.dump('foo'))).to be_frozen
    end

    it 'is thread safe' do
      pool = factory.pool(1)

      threads = 10.times.map do
        Thread.new do
          1_000.times do |i|
            expect(pool.load(pool.dump(i))).to be == i
          end
        end
      end
      threads.each(&:join)
    end
  end
end
