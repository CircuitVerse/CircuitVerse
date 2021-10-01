# frozen_string_literal: true

module ServiceWorker
  class Route
    attr_reader :path_pattern, :asset_pattern, :options

    RouteMatch = Struct.new(:path, :asset_name, :headers, :options) do
      def to_s
        asset_name
      end
    end

    def self.webpacker?(options)
      options.key?(:pack) && Handlers.webpacker?
    end

    def self.sprockets?(options)
      options.key?(:asset)
    end

    def initialize(path_pattern, asset_pattern = nil, options = {})
      if asset_pattern.is_a?(Hash)
        options = asset_pattern
        asset_pattern = nil
      end

      @path_pattern = path_pattern
      @asset_pattern = if self.class.webpacker?(options)
                         asset_pattern || options.fetch(:pack, path_pattern)
                       else
                         asset_pattern || options.fetch(:asset, path_pattern)
                       end
      @options = options
    end

    def match(path)
      raise ArgumentError, "path is required" if path.to_s.strip.empty?

      asset = resolver.call(path) or return nil

      RouteMatch.new(path, asset, headers, options)
    end

    def headers
      @options.fetch(:headers, {})
    end

    private

    def resolver
      @resolver ||= AssetResolver.new(path_pattern, asset_pattern)
    end

    class AssetResolver
      PATH_INFO = "PATH_INFO"
      DEFAULT_WILDCARD_NAME = :paths
      WILDCARD_PATTERN = %r{\/\*([^\/]*)}.freeze
      NAMED_SEGMENTS_PATTERN = %r{\/([^\/]*):([^:$\/]+)}.freeze
      LEADING_SLASH_PATTERN = %r{^\/}.freeze
      INTERPOLATION_PATTERN = Regexp.union(
        /%%/,
        /%\{(\w+)\}/ # matches placeholders like "%{foo}"
      )

      attr_reader :path_pattern, :asset_pattern

      def initialize(path_pattern, asset_pattern)
        @path_pattern = path_pattern
        @asset_pattern = asset_pattern
      end

      def call(path)
        raise ArgumentError, "path is required" if path.to_s.strip.empty?

        captures = path_captures(regexp, path) or return nil

        interpolate_captures(asset_pattern, captures)
      end

      private

      def regexp
        @regexp ||= compile_regexp(path_pattern)
      end

      def compile_regexp(pattern)
        Regexp.new("\\A#{compiled_source(pattern)}\\Z")
      end

      def compiled_source(pattern)
        @wildcard_name = nil
        pattern_match = pattern.match(WILDCARD_PATTERN)
        if pattern_match
          @wildcard_name = if pattern_match[1].to_s.strip.empty?
                             DEFAULT_WILDCARD_NAME
                           else
                             pattern_match[1].to_sym
                           end
          pattern.gsub(WILDCARD_PATTERN, "(?:/(.*)|)")
        else
          p = if pattern.match(NAMED_SEGMENTS_PATTERN)
                pattern.gsub(NAMED_SEGMENTS_PATTERN, '/\1(?<\2>[^.$/]+)')
              else
                pattern
              end
          p + '(?:\.(?<format>.*))?'
        end
      end

      def path_captures(regexp, path)
        path_match = path.match(regexp) or return nil
        params = if @wildcard_name
                   { @wildcard_name => path_match[1].to_s.split("/") }
                 else
                   Hash[path_match.names.map(&:to_sym).zip(path_match.captures)]
                 end
        params.delete(:format) if params.key?(:format) && params[:format].nil?
        params
      end

      def interpolate_captures(string, captures)
        string.gsub(INTERPOLATION_PATTERN) do |match|
          if match == "%%"
            "%"
          else
            key = (Regexp.last_match(1) || Regexp.last_match(2)).to_sym
            value = captures.key?(key) ? Array(captures[key]).join("/") : key
            value = value.call(captures) if value.respond_to?(:call)
            Regexp.last_match(3) ? format("%#{Regexp.last_match(3)}", value) : value
          end
        end.gsub(LEADING_SLASH_PATTERN, "")
      end
    end
  end
end
