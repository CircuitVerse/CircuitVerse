# frozen_string_literal: true

module Glob
  class Object
    PATH_SPLIT_RE = /(?<!\\)\./.freeze

    attr_reader :matchers

    def initialize(target)
      @target = target
      @matchers = []
    end

    def <<(path)
      matchers << Matcher.new(path)
    end
    alias filter <<

    def to_h
      symbolized_target = SymbolizeKeys.call(@target)

      paths.each_with_object({}) do |path, buffer|
        segments = path.split(PATH_SPLIT_RE).map {|key| unescape(key).to_sym }
        value = symbolized_target.dig(*segments)
        set_path_value(segments, buffer, value)
      end
    end
    alias to_hash to_h

    def set(path, value)
      set_path_value(path.split(PATH_SPLIT_RE), @target, value)
      @map = Map.call(@target)

      nil
    end

    def paths
      matches = map.map do |path|
        results = matchers.select {|matcher| matcher.match?(path) } # rubocop:disable Style/SelectByRegexp
        [path, results]
      end

      matches
        .select {|(_, results)| results.compact.last&.include? }
        .map {|(path)| path }
        .sort
    end

    private def map
      @map ||= Map.call(@target)
    end

    private def unescape(key)
      key.to_s.gsub("\\.", ".")
    end

    private def set_path_value(segments, target, value)
      segments = segments.dup.map(&:to_sym)

      while (segment = segments.shift)
        if segments.empty?
          target[segment] = value
        else
          target[segment] ||= {}
          target[segment] = {} unless target[segment].is_a?(Hash)
          target = target[segment]
        end
      end
    end
  end
end
