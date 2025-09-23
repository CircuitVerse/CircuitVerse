# frozen_string_literal: true

module Glob
  class Matcher
    attr_reader :path, :regex

    def initialize(path)
      @path = path
      @reject = path.start_with?("!")

      pattern = Regexp.escape(path.gsub(/^!/, ""))
                      .gsub(/(\\{.*?\\})/) {|match| process_group(match) }
                      .gsub("\\*", "[^.]+")
      anchor = path.end_with?("*") ? "" : "$"
      @regex = Regexp.new("^#{pattern}#{anchor}")
    end

    def match?(other)
      other.match?(regex)
    end

    def include?
      !reject?
    end

    def reject?
      @reject
    end

    def process_group(group)
      group = group.gsub(/[{}\\]/, "").split(",").join("|")

      "(#{group})"
    end
  end
end
