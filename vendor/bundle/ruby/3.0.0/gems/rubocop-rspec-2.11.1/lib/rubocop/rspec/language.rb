# frozen_string_literal: true

module RuboCop
  module RSpec
    # Contains node matchers for common RSpec DSL.
    #
    # RSpec allows for configuring aliases for commonly used DSL elements, e.g.
    # example groups and hooks. It is possible to configure RuboCop RSpec to
    # be able to properly detect these elements in the `RSpec/Language` section
    # of the RuboCop YAML configuration file.
    #
    # In addition to providing useful matchers, this class is responsible for
    # using the configured aliases.
    module Language
      extend RuboCop::NodePattern::Macros
      extend NodePattern

      class << self
        attr_accessor :config
      end

      # @!method rspec?(node)
      def_node_matcher :rspec?, '{(const {nil? cbase} :RSpec) nil?}'

      # @!method example_group?(node)
      def_node_matcher :example_group?, block_pattern('#ExampleGroups.all')

      # @!method shared_group?(node)
      def_node_matcher :shared_group?, block_pattern('#SharedGroups.all')

      # @!method spec_group?(node)
      def_node_matcher :spec_group?,
                       block_pattern('{#SharedGroups.all #ExampleGroups.all}')

      # @!method example_group_with_body?(node)
      def_node_matcher :example_group_with_body?, <<-PATTERN
        (block #{send_pattern('#ExampleGroups.all')} args !nil?)
      PATTERN

      # @!method example?(node)
      def_node_matcher :example?, block_pattern('#Examples.all')

      # @!method hook?(node)
      def_node_matcher :hook?, block_pattern('#Hooks.all')

      # @!method let?(node)
      def_node_matcher :let?, <<-PATTERN
        {
          #{block_pattern('#Helpers.all')}
          (send #rspec? #Helpers.all _ block_pass)
        }
      PATTERN

      # @!method include?(node)
      def_node_matcher :include?, <<-PATTERN
        {
          #{send_pattern('#Includes.all')}
          #{block_pattern('#Includes.all')}
        }
      PATTERN

      # @!method subject?(node)
      def_node_matcher :subject?, block_pattern('#Subjects.all')

      module ExampleGroups # :nodoc:
        class << self
          def all(element)
            regular(element) ||
              skipped(element) ||
              focused(element)
          end

          def regular(element)
            Language.config['ExampleGroups']['Regular'].include?(element.to_s)
          end

          def focused(element)
            Language.config['ExampleGroups']['Focused'].include?(element.to_s)
          end

          def skipped(element)
            Language.config['ExampleGroups']['Skipped'].include?(element.to_s)
          end
        end
      end

      module Examples # :nodoc:
        class << self
          def all(element)
            regular(element) ||
              focused(element) ||
              skipped(element) ||
              pending(element)
          end

          def regular(element)
            Language.config['Examples']['Regular'].include?(element.to_s)
          end

          def focused(element)
            Language.config['Examples']['Focused'].include?(element.to_s)
          end

          def skipped(element)
            Language.config['Examples']['Skipped'].include?(element.to_s)
          end

          def pending(element)
            Language.config['Examples']['Pending'].include?(element.to_s)
          end
        end
      end

      module Expectations # :nodoc:
        def self.all(element)
          Language.config['Expectations'].include?(element.to_s)
        end
      end

      module Helpers # :nodoc:
        def self.all(element)
          Language.config['Helpers'].include?(element.to_s)
        end
      end

      module Hooks # :nodoc:
        def self.all(element)
          Language.config['Hooks'].include?(element.to_s)
        end
      end

      module HookScopes # :nodoc:
        def self.all(element)
          Language.config['HookScopes'].include?(element.to_s)
        end
      end

      module Includes # :nodoc:
        class << self
          def all(element)
            examples(element) ||
              context(element)
          end

          def examples(element)
            Language.config['Includes']['Examples'].include?(element.to_s)
          end

          def context(element)
            Language.config['Includes']['Context'].include?(element.to_s)
          end
        end
      end

      module Runners # :nodoc:
        def self.all(element)
          Language.config['Runners'].include?(element.to_s)
        end
      end

      module SharedGroups # :nodoc:
        class << self
          def all(element)
            examples(element) ||
              context(element)
          end

          def examples(element)
            Language.config['SharedGroups']['Examples'].include?(element.to_s)
          end

          def context(element)
            Language.config['SharedGroups']['Context'].include?(element.to_s)
          end
        end
      end

      module Subjects # :nodoc:
        def self.all(element)
          Language.config['Subjects'].include?(element.to_s)
        end
      end

      # This is used in Dialect and DescribeClass cops to detect RSpec blocks.
      module ALL # :nodoc:
        def self.all(element)
          [ExampleGroups, Examples, Expectations, Helpers, Hooks, Includes,
           Runners, SharedGroups, Subjects]
            .find { |concept| concept.all(element) }
        end
      end

      private_constant :ExampleGroups, :Examples, :Expectations, :Hooks,
                       :Includes, :Runners, :SharedGroups, :ALL
    end
  end
end
