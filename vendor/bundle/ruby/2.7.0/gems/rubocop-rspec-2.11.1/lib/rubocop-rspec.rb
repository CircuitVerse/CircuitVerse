# frozen_string_literal: true

require 'pathname'
require 'yaml'

require 'rubocop'

require_relative 'rubocop/rspec/version'
require_relative 'rubocop/rspec/inject'
require_relative 'rubocop/rspec/node'
require_relative 'rubocop/rspec/wording'
require_relative 'rubocop/rspec/language/node_pattern'
require_relative 'rubocop/rspec/language'

require_relative 'rubocop/rspec/factory_bot/language'

require_relative 'rubocop/cop/rspec/mixin/top_level_group'
require_relative 'rubocop/cop/rspec/mixin/variable'
require_relative 'rubocop/cop/rspec/mixin/final_end_location'
require_relative 'rubocop/cop/rspec/mixin/comments_help'
require_relative 'rubocop/cop/rspec/mixin/empty_line_separation'
require_relative 'rubocop/cop/rspec/mixin/inside_example_group'

require_relative 'rubocop/rspec/concept'
require_relative 'rubocop/rspec/example_group'
require_relative 'rubocop/rspec/example'
require_relative 'rubocop/rspec/hook'
require_relative 'rubocop/cop/rspec/base'
require_relative 'rubocop/rspec/align_let_brace'
require_relative 'rubocop/rspec/factory_bot'
require_relative 'rubocop/rspec/corrector/move_node'

RuboCop::RSpec::Inject.defaults!

require_relative 'rubocop/cop/rspec_cops'

# We have to register our autocorrect incompatibilities in RuboCop's cops
# as well so we do not hit infinite loops

RuboCop::Cop::Layout::ExtraSpacing.singleton_class.prepend(
  Module.new do
    def autocorrect_incompatible_with
      super.push(RuboCop::Cop::RSpec::AlignLeftLetBrace)
      .push(RuboCop::Cop::RSpec::AlignRightLetBrace)
    end
  end
)

RuboCop::Cop::Style::TrailingCommaInArguments.singleton_class.prepend(
  Module.new do
    def autocorrect_incompatible_with
      super.push(RuboCop::Cop::RSpec::Capybara::CurrentPathExpectation)
    end
  end
)

RuboCop::AST::Node.include(RuboCop::RSpec::Node)
