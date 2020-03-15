# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that no class, module, or constant is declared.
      #
      # Constants, including classes and modules, when declared in a block
      # scope, are defined in global namespace, and leak between examples.
      #
      # If several examples may define a `DummyClass`, instead of being a
      # blank slate class as it will be in the first example, subsequent
      # examples will be reopening it and modifying its behaviour in
      # unpredictable ways.
      # Even worse when a class that exists in the codebase is reopened.
      #
      # Anonymous classes are fine, since they don't result in global
      # namespace name clashes.
      #
      # @see https://relishapp.com/rspec/rspec-mocks/docs/mutating-constants
      #
      # @example Constants leak between examples
      #   # bad
      #   describe SomeClass do
      #     OtherClass = Struct.new
      #     CONSTANT_HERE = 'I leak into global namespace'
      #   end
      #
      #   # good
      #   describe SomeClass do
      #     before do
      #       stub_const('OtherClass', Struct.new)
      #       stub_const('CONSTANT_HERE', 'I only exist during this example')
      #     end
      #   end
      #
      # @example
      #   # bad
      #   describe SomeClass do
      #     class FooClass < described_class
      #       def double_that
      #         some_base_method * 2
      #       end
      #     end
      #
      #     it { expect(FooClass.new.double_that).to eq(4) }
      #   end
      #
      #   # good - anonymous class, no constant needs to be defined
      #   describe SomeClass do
      #     let(:foo_class) do
      #       Class.new(described_class) do
      #         def double_that
      #           some_base_method * 2
      #         end
      #       end
      #     end
      #
      #     it { expect(foo_class.new.double_that).to eq(4) }
      #   end
      #
      #   # good - constant is stubbed
      #   describe SomeClass do
      #     before do
      #       foo_class = Class.new(described_class) do
      #                     def do_something
      #                     end
      #                   end
      #       stub_const('FooClass', foo_class)
      #     end
      #
      #     it { expect(FooClass.new.double_that).to eq(4) }
      #   end
      #
      # @example
      #   # bad
      #   describe SomeClass do
      #     module SomeModule
      #       class SomeClass
      #         def do_something
      #         end
      #       end
      #     end
      #   end
      #
      #   # good
      #   describe SomeClass do
      #     before do
      #       foo_class = Class.new(described_class) do
      #                     def do_something
      #                     end
      #                   end
      #       stub_const('SomeModule::SomeClass', foo_class)
      #     end
      #   end
      class LeakyConstantDeclaration < Cop
        MSG_CONST = 'Stub constant instead of declaring explicitly.'
        MSG_CLASS = 'Stub class constant instead of declaring explicitly.'
        MSG_MODULE = 'Stub module constant instead of declaring explicitly.'

        def on_casgn(node)
          return unless inside_describe_block?(node)

          add_offense(node, message: MSG_CONST)
        end

        def on_class(node)
          return unless inside_describe_block?(node)

          add_offense(node, message: MSG_CLASS)
        end

        def on_module(node)
          return unless inside_describe_block?(node)

          add_offense(node, message: MSG_MODULE)
        end

        private

        def inside_describe_block?(node)
          node.each_ancestor(:block).any?(&method(:in_example_or_shared_group?))
        end

        def_node_matcher :in_example_or_shared_group?,
                         (ExampleGroups::ALL + SharedGroups::ALL).block_pattern
      end
    end
  end
end
