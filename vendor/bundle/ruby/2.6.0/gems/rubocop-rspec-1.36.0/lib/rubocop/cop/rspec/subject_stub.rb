# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for stubbed test subjects.
      #
      # @see https://robots.thoughtbot.com/don-t-stub-the-system-under-test
      # @see https://samphippen.com/introducing-rspec-smells-and-where-to-find-them#smell-1-stubject
      # @see https://github.com/rubocop-hq/rspec-style-guide#dont-stub-subject
      #
      # @example
      #   # bad
      #   describe Foo do
      #     subject(:bar) { baz }
      #
      #     before do
      #       allow(bar).to receive(:qux?).and_return(true)
      #     end
      #   end
      #
      class SubjectStub < Cop
        MSG = 'Do not stub methods of the object under test.'

        # @!method subject(node)
        #   Find a named or unnamed subject definition
        #
        #   @example anonymous subject
        #     subject(parse('subject { foo }').ast) do |name|
        #       name # => :subject
        #     end
        #
        #   @example named subject
        #     subject(parse('subject(:thing) { foo }').ast) do |name|
        #       name # => :thing
        #     end
        #
        #   @param node [RuboCop::Node]
        #
        #   @yield [Symbol] subject name
        def_node_matcher :subject, <<-PATTERN
          {
            (block (send nil? :subject (sym $_)) args ...)
            (block (send nil? $:subject) args ...)
          }
        PATTERN

        # @!method message_expectation?(node, method_name)
        #   Match `allow` and `expect(...).to receive`
        #
        #   @example source that matches
        #     allow(foo).to  receive(:bar)
        #     allow(foo).to  receive(:bar).with(1)
        #     allow(foo).to  receive(:bar).with(1).and_return(2)
        #     expect(foo).to receive(:bar)
        #     expect(foo).to receive(:bar).with(1)
        #     expect(foo).to receive(:bar).with(1).and_return(2)
        #
        def_node_matcher :message_expectation?, <<-PATTERN
          (send
            {
              (send nil? { :expect :allow } (send nil? {% :subject}))
              (send nil? :is_expected)
            }
            #{Runners::ALL.node_pattern_union}
            #message_expectation_matcher?
          )
        PATTERN

        def_node_search :message_expectation_matcher?, <<-PATTERN
          (send nil? {
            :receive :receive_messages :receive_message_chain :have_received
            } ...)
        PATTERN

        def on_block(node)
          return unless example_group?(node)

          find_subject_stub(node) do |stub|
            add_offense(stub)
          end
        end

        private

        # Find subjects within tree and then find (send) nodes for that subject
        #
        # @param node [RuboCop::Node] example group
        #
        # @yield [RuboCop::Node] message expectations for subject
        def find_subject_stub(node, &block)
          find_subject(node) do |subject_name, context|
            find_subject_expectation(context, subject_name, &block)
          end
        end

        # Find a subject message expectation
        #
        # @param node [RuboCop::Node]
        # @param subject_name [Symbol] name of subject
        #
        # @yield [RuboCop::Node] message expectation
        def find_subject_expectation(node, subject_name, &block)
          # Do not search node if it is an example group with its own subject.
          return if example_group?(node) && redefines_subject?(node)

          # Yield the current node if it is a message expectation.
          yield(node) if message_expectation?(node, subject_name)

          # Recurse through node's children looking for a message expectation.
          node.each_child_node do |child|
            find_subject_expectation(child, subject_name, &block)
          end
        end

        # Check if node's children contain a subject definition
        #
        # @param node [RuboCop::Node]
        #
        # @return [Boolean]
        def redefines_subject?(node)
          node.each_child_node.any? do |child|
            subject(child) || redefines_subject?(child)
          end
        end

        # Find a subject definition
        #
        # @param node [RuboCop::Node]
        # @param parent [RuboCop::Node,nil]
        #
        # @yieldparam subject_name [Symbol] name of subject being defined
        # @yieldparam parent [RuboCop::Node] parent of subject definition
        def find_subject(node, parent: nil, &block)
          subject(node) { |name| yield(name, parent) }

          node.each_child_node do |child|
            find_subject(child, parent: node, &block)
          end
        end
      end
    end
  end
end
