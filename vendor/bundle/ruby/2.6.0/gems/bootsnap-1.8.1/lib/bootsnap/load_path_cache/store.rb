# frozen_string_literal: true
require_relative('../explicit_require')

Bootsnap::ExplicitRequire.with_gems('msgpack') { require('msgpack') }
Bootsnap::ExplicitRequire.from_rubylibdir('fileutils')

module Bootsnap
  module LoadPathCache
    class Store
      NestedTransactionError = Class.new(StandardError)
      SetOutsideTransactionNotAllowed = Class.new(StandardError)

      def initialize(store_path)
        @store_path = store_path
        @txn_mutex = Mutex.new
        @dirty = false
        load_data
      end

      def get(key)
        @data[key]
      end

      def fetch(key)
        raise(SetOutsideTransactionNotAllowed) unless @txn_mutex.owned?
        v = get(key)
        unless v
          @dirty = true
          v = yield
          @data[key] = v
        end
        v
      end

      def set(key, value)
        raise(SetOutsideTransactionNotAllowed) unless @txn_mutex.owned?
        if value != @data[key]
          @dirty = true
          @data[key] = value
        end
      end

      def transaction
        raise(NestedTransactionError) if @txn_mutex.owned?
        @txn_mutex.synchronize do
          begin
            yield
          ensure
            commit_transaction
          end
        end
      end

      private

      def commit_transaction
        if @dirty
          dump_data
          @dirty = false
        end
      end

      def load_data
        @data = begin
          File.open(@store_path, encoding: Encoding::BINARY) do |io|
            MessagePack.load(io)
          end
        # handle malformed data due to upgrade incompatibility
        rescue Errno::ENOENT, MessagePack::MalformedFormatError, MessagePack::UnknownExtTypeError, EOFError
          {}
        rescue ArgumentError => error
          if error.message =~ /negative array size/
            {}
          else
            raise
          end
        end
      end

      def dump_data
        # Change contents atomically so other processes can't get invalid
        # caches if they read at an inopportune time.
        tmp = "#{@store_path}.#{Process.pid}.#{(rand * 100000).to_i}.tmp"
        FileUtils.mkpath(File.dirname(tmp))
        exclusive_write = File::Constants::CREAT | File::Constants::EXCL | File::Constants::WRONLY
        # `encoding:` looks redundant wrt `binwrite`, but necessary on windows
        # because binary is part of mode.
        File.open(tmp, mode: exclusive_write, encoding: Encoding::BINARY) do |io|
          MessagePack.dump(@data, io, freeze: true)
        end
        FileUtils.mv(tmp, @store_path)
      rescue Errno::EEXIST
        retry
      rescue SystemCallError
      end
    end
  end
end
