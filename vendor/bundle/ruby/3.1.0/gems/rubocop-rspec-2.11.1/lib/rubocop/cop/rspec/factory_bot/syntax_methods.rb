# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module FactoryBot
        # Use shorthands from `FactoryBot::Syntax::Methods` in your specs.
        #
        # @safety
        #   The auto-correction is marked as unsafe because the cop
        #   cannot verify whether you already include
        #   `FactoryBot::Syntax::Methods` in your test suite.
        #
        #   If you're using Rails, add the following configuration to
        #   `spec/support/factory_bot.rb` and be sure to require that file in
        #   `rails_helper.rb`:
        #
        #   [source,ruby]
        #   ----
        #   RSpec.configure do |config|
        #     config.include FactoryBot::Syntax::Methods
        #   end
        #   ----
        #
        #   If you're not using Rails:
        #
        #   [source,ruby]
        #   ----
        #   RSpec.configure do |config|
        #     config.include FactoryBot::Syntax::Methods
        #
        #     config.before(:suite) do
        #       FactoryBot.find_definitions
        #     end
        #   end
        #   ----
        #
        # @example
        #   # bad
        #   FactoryBot.create(:bar)
        #   FactoryBot.build(:bar)
        #   FactoryBot.attributes_for(:bar)
        #
        #   # good
        #   create(:bar)
        #   build(:bar)
        #   attributes_for(:bar)
        #
        class SyntaxMethods < Base
          extend AutoCorrector
          include InsideExampleGroup
          include RangeHelp
          include RuboCop::RSpec::FactoryBot::Language

          MSG = 'Use `%<method>s` from `FactoryBot::Syntax::Methods`.'

          RESTRICT_ON_SEND = %i[
            attributes_for
            attributes_for_list
            attributes_for_pair
            build
            build_list
            build_pair
            build_stubbed
            build_stubbed_list
            build_stubbed_pair
            create
            create_list
            create_pair
            generate
            generate_list
            null
            null_list
            null_pair
          ].to_set.freeze

          def on_send(node)
            return unless factory_bot?(node.receiver)
            return unless inside_example_group?(node)

            message = format(MSG, method: node.method_name)

            add_offense(crime_scene(node), message: message) do |corrector|
              corrector.remove(offense(node))
            end
          end

          private

          def crime_scene(node)
            range_between(
              node.loc.expression.begin_pos,
              node.loc.selector.end_pos
            )
          end

          def offense(node)
            range_between(
              node.loc.expression.begin_pos,
              node.loc.selector.begin_pos
            )
          end
        end
      end
    end
  end
end
