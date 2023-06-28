module AwsRecord
  module Generators
    class SecondaryIndex

      PROJ_TYPES = %w(ALL KEYS_ONLY INCLUDE)
      attr_reader :name, :hash_key, :range_key, :projection_type

      class << self
        def parse(key_definition)
          name, index_options = key_definition.split(':')
          index_options = index_options.split(',') if index_options
          opts = parse_raw_options(index_options)

          new(name, opts)
        end

        private
          def parse_raw_options(raw_opts)
            raw_opts = [] if not raw_opts
            raw_opts.map { |opt| get_option_value(opt) }.to_h
          end

          def get_option_value(raw_option)
            case raw_option

            when /hkey\{(\w+)\}/
              return :hash_key, $1
            when /rkey\{(\w+)\}/
              return :range_key, $1
            when /proj_type\{(\w+)\}/
              return :projection_type, $1
            else
              raise ArgumentError.new("Invalid option for secondary index #{raw_option}")
            end
          end
      end

      def initialize(name, opts)
        raise ArgumentError.new("You must provide a name") if not name
        raise ArgumentError.new("You must provide a hash key") if not opts[:hash_key]

        if opts.key? :projection_type
          raise ArgumentError.new("Invalid projection type #{opts[:projection_type]}") if not PROJ_TYPES.include? opts[:projection_type]
          raise NotImplementedError.new("ALL is the only projection type currently supported") if opts[:projection_type] != "ALL"
        else
          opts[:projection_type] = "ALL"
        end

        if opts[:hash_key] == opts[:range_key]
          raise ArgumentError.new("#{opts[:hash_key]} cannot be both the rkey and hkey for gsi #{name}")
        end

        @name = name
        @hash_key = opts[:hash_key]
        @range_key = opts[:range_key]
        @projection_type = '"' + "#{opts[:projection_type]}" + '"'
      end
    end
  end
end
