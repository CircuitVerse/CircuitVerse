# frozen_string_literal: true

require_relative "glob/map"
require_relative "glob/object"
require_relative "glob/matcher"
require_relative "glob/symbolize_keys"
require_relative "glob/version"

module Glob
  def self.filter(target, paths = ["*"])
    glob = new(target)
    paths.each {|path| glob.filter(path) }
    glob.to_h
  end

  def self.new(target = {})
    Object.new(target)
  end
end
