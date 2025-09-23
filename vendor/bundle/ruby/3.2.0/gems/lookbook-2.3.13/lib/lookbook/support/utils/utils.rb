module Lookbook
  module Utils
    class << self
      def id(*args)
        parts = args.map { |arg| arg.to_s }
        id_str = parts.join("-").force_encoding("UTF-8").parameterize.dasherize
        PathUtils.strip_slashes(id_str).tr("/", "-").gsub("--", "-")
      end

      def temp_id(prefix: nil)
        [prefix, (Time.now.to_f * 1000).to_i + rand(0..100)].compact.join("-")
      end

      def name(str)
        str.to_s.dup.force_encoding("UTF-8").parameterize.tr("-", "_")
      end

      def symbolize_name(str)
        name(str).to_sym
      end

      def value_or_fallback(value, fallback = nil, &block)
        if value.nil?
          fallback_block = block || proc { fallback }
          fallback_block.call
        else
          value
        end
      end
    end
  end
end
