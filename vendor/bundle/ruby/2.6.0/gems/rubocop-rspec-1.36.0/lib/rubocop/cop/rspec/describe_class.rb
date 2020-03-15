# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Check that the first argument to the top level describe is a constant.
      #
      # @example
      #   # bad
      #   describe 'Do something' do
      #   end
      #
      #   # good
      #   describe TestedClass do
      #   end
      #
      #   describe "A feature example", type: :feature do
      #   end
      class DescribeClass < Cop
        include RuboCop::RSpec::TopLevelDescribe

        MSG = 'The first argument to describe should be '\
              'the class or module being tested.'

        def_node_matcher :valid_describe?, <<-PATTERN
          {
            (send #{RSPEC} :describe const ...)
            (send #{RSPEC} :describe)
          }
        PATTERN

        def_node_matcher :describe_with_rails_metadata?, <<-PATTERN
          (send #{RSPEC} :describe !const ...
            (hash <#rails_metadata? ...>)
          )
        PATTERN

        def_node_matcher :rails_metadata?, <<-PATTERN
          (pair
            (sym :type)
            (sym {:request :feature :system :routing :view})
          )
        PATTERN

        def_node_matcher :shared_group?, SharedGroups::ALL.block_pattern

        def on_top_level_describe(node, args)
          return if shared_group?(root_node)
          return if valid_describe?(node)
          return if describe_with_rails_metadata?(node)

          add_offense(args.first)
        end
      end
    end
  end
end
