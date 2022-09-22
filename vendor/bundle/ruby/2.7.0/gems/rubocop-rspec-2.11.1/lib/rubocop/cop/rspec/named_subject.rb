# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for explicitly referenced test subjects.
      #
      # RSpec lets you declare an "implicit subject" using `subject { ... }`
      # which allows for tests like `it { is_expected.to be_valid }`.
      # If you need to reference your test subject you should explicitly
      # name it using `subject(:your_subject_name) { ... }`. Your test subjects
      # should be the most important object in your tests so they deserve
      # a descriptive name.
      #
      # This cop can be configured in your configuration using the
      # `IgnoreSharedExamples` which will not report offenses for implicit
      # subjects in shared example groups.
      #
      # @example
      #   # bad
      #   RSpec.describe User do
      #     subject { described_class.new }
      #
      #     it 'is valid' do
      #       expect(subject.valid?).to be(true)
      #     end
      #   end
      #
      #   # good
      #   RSpec.describe Foo do
      #     subject(:user) { described_class.new }
      #
      #     it 'is valid' do
      #       expect(user.valid?).to be(true)
      #     end
      #   end
      #
      #   # also good
      #   RSpec.describe Foo do
      #     subject(:user) { described_class.new }
      #
      #     it { is_expected.to be_valid }
      #   end
      class NamedSubject < Base
        MSG = 'Name your test subject if you need to reference it explicitly.'

        # @!method example_or_hook_block?(node)
        def_node_matcher :example_or_hook_block?,
                         block_pattern('{#Examples.all #Hooks.all}')

        # @!method shared_example?(node)
        def_node_matcher :shared_example?,
                         block_pattern('#SharedGroups.examples')

        # @!method subject_usage(node)
        def_node_search :subject_usage, '$(send nil? :subject)'

        def on_block(node)
          if !example_or_hook_block?(node) || ignored_shared_example?(node)
            return
          end

          subject_usage(node) do |subject_node|
            add_offense(subject_node.loc.selector)
          end
        end

        def ignored_shared_example?(node)
          cop_config['IgnoreSharedExamples'] &&
            node.each_ancestor(:block).any?(&method(:shared_example?))
        end
      end
    end
  end
end
