# frozen_string_literal: true

module Zeitwerk
  require_relative "zeitwerk/real_mod_name"
  require_relative "zeitwerk/internal"
  require_relative "zeitwerk/cref"
  require_relative "zeitwerk/loader"
  require_relative "zeitwerk/gem_loader"
  require_relative "zeitwerk/registry"
  require_relative "zeitwerk/inflector"
  require_relative "zeitwerk/gem_inflector"
  require_relative "zeitwerk/null_inflector"
  require_relative "zeitwerk/error"
  require_relative "zeitwerk/version"

  require_relative "zeitwerk/core_ext/kernel"
  require_relative "zeitwerk/core_ext/module"

  # This is a dangerous method.
  #
  # @experimental
  #: () -> void
  def self.with_loader
    loader = Zeitwerk::Loader.new
    yield loader
  ensure
    loader.unregister
  end
end
