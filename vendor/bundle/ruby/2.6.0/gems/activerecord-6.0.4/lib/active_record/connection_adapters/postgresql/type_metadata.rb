# frozen_string_literal: true

module ActiveRecord
  # :stopdoc:
  module ConnectionAdapters
    module PostgreSQL
      class TypeMetadata < DelegateClass(SqlTypeMetadata)
        undef to_yaml if method_defined?(:to_yaml)

        attr_reader :oid, :fmod

        def initialize(type_metadata, oid: nil, fmod: nil)
          super(type_metadata)
          @oid = oid
          @fmod = fmod
        end

        def ==(other)
          other.is_a?(TypeMetadata) &&
            __getobj__ == other.__getobj__ &&
            oid == other.oid &&
            fmod == other.fmod
        end
        alias eql? ==

        def hash
          TypeMetadata.hash ^
            __getobj__.hash ^
            oid.hash ^
            fmod.hash
        end
      end
    end
    PostgreSQLTypeMetadata = PostgreSQL::TypeMetadata
  end
end
