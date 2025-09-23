# frozen_string_literal: true

require 'yard'
require_relative "solargraph/version"

module YARD
  module Solargraph
    # Define a @yieldreceiver tag for documenting the receiver of a block
    #
    # @example
    #   # @yieldreceiver [Array] An array will evaluate the block
    #   def add5_block(&block) [].instance_eval(&block) end
    #
    YARD::Tags::Library.define_tag('Yield Receiver', :yieldreceiver, :with_types)

    # Define a @generic tag for documenting generic classes
    #
    # @example
    #   # @generic T
    #   class Example
    #     # @return [generic<T>]
    #     attr_reader :value
    #   end
    #
    #   # @return [Example<String>]
    #   def string_example; end
    #
    #   string_example.value # => String
    #
    YARD::Tags::Library.define_tag('Generics', :generic, :with_types_and_name)

    YARD::Tags::Library.visible_tags.push :yieldreceiver, :generic
  end
end
