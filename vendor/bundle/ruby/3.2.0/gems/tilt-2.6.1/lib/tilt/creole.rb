# frozen_string_literal: true
require_relative 'template'
require 'creole'

warn 'tilt/creole is deprecated, as creole requires modifying string literals', uplevel: 1

allowed_opts = [:allowed_schemes, :extensions, :no_escape].freeze

# Creole implementation. See: http://www.wikicreole.org/
Tilt::CreoleTemplate = Tilt::StaticTemplate.subclass do
  opts = {}
  allowed_opts.each do |k|
    opts[k] = @options[k] if @options[k]
  end
  Creole::Parser.new(@data, opts).to_html
end
