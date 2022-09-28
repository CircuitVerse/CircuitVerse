module MessagePack
  class Factory
    # see ext for other methods

    # [ {type: id, class: Class(or nil), packer: arg, unpacker: arg}, ... ]
    def registered_types(selector=:both)
      packer, unpacker = registered_types_internal
      # packer: Class -> [tid, proc, arg]
      # unpacker: tid -> [klass, proc, arg]

      list = []

      case selector
      when :both
        packer.each_pair do |klass, ary|
          type = ary[0]
          packer_arg = ary[2]
          unpacker_arg = nil
          if unpacker.has_key?(type) && unpacker[type][0] == klass
            unpacker_arg = unpacker.delete(type)[2]
          end
          list << {type: type, class: klass, packer: packer_arg, unpacker: unpacker_arg}
        end

        # unpacker definition only
        unpacker.each_pair do |type, ary|
          list << {type: type, class: ary[0], packer: nil, unpacker: ary[2]}
        end

      when :packer
        packer.each_pair do |klass, ary|
          list << {type: ary[0], class: klass, packer: ary[2]}
        end

      when :unpacker
        unpacker.each_pair do |type, ary|
          list << {type: type, class: ary[0], unpacker: ary[2]}
        end

      else
        raise ArgumentError, "invalid selector #{selector}"
      end

      list.sort{|a, b| a[:type] <=> b[:type] }
    end

    def type_registered?(klass_or_type, selector=:both)
      case klass_or_type
      when Class
        klass = klass_or_type
        registered_types(selector).any?{|entry| klass <= entry[:class] }
      when Integer
        type = klass_or_type
        registered_types(selector).any?{|entry| type == entry[:type] }
      else
        raise ArgumentError, "class or type id"
      end
    end

    def load(src, param = nil)
      unpacker = nil

      if src.is_a? String
        unpacker = unpacker(param)
        unpacker.feed(src)
      else
        unpacker = unpacker(src, param)
      end

      unpacker.full_unpack
    end
    alias :unpack :load

    def dump(v, *rest)
      packer = packer(*rest)
      packer.write(v)
      packer.full_pack
    end
    alias :pack :dump

    def pool(size = 1, **options)
      Pool.new(
        frozen? ? self : dup.freeze,
        size,
        options.empty? ? nil : options,
      )
    end

    class Pool
      if RUBY_ENGINE == "ruby"
        class AbstractPool
          def initialize(size, &block)
            @size = size
            @new_member = block
            @members = []
          end

          def checkout
            @members.pop || @new_member.call
          end

          def checkin(member)
            # If the pool is already full, we simply drop the extra member.
            # This is because contrary to a connection pool, creating an extra instance
            # is extremely unlikely to cause some kind of resource exhaustion.
            #
            # We could cycle the members (keep the newer one) but first It's more work and second
            # the older member might have been created pre-fork, so it might be at least partially
            # in shared memory.
            if member && @members.size < @size
              member.reset
              @members << member
            end
          end
        end
      else
        class AbstractPool
          def initialize(size, &block)
            @size = size
            @new_member = block
            @members = []
            @mutex = Mutex.new
          end

          def checkout
            @mutex.synchronize { @members.pop } || @new_member.call
          end

          def checkin(member)
            @mutex.synchronize do
              if member && @members.size < @size
                member.reset
                @members << member
              end
            end
          end
        end
      end

      class PackerPool < AbstractPool
        private

        def reset(packer)
          packer.clear
        end
      end

      class UnpackerPool < AbstractPool
        private

        def reset(unpacker)
          unpacker.reset
        end
      end

      def initialize(factory, size, options = nil)
        options = nil if !options || options.empty?
        @factory = factory
        @packers = PackerPool.new(size) { factory.packer(options) }
        @unpackers = UnpackerPool.new(size) { factory.unpacker(options) }
      end

      def load(data)
        unpacker = @unpackers.checkout
        begin
          unpacker.feed_reference(data)
          unpacker.full_unpack
        ensure
          @unpackers.checkin(unpacker)
        end
      end

      def dump(object)
        packer = @packers.checkout
        begin
          packer.write(object)
          packer.full_pack
        ensure
          @packers.checkin(packer)
        end
      end
    end
  end
end
