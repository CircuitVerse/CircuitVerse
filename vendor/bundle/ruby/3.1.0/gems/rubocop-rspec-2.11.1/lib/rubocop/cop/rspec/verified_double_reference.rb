# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for consistent verified double reference style.
      #
      # Only investigates references that are one of the supported styles.
      #
      # @see https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles
      #
      # This cop can be configured in your configuration using the
      # `EnforcedStyle` option and supports `--auto-gen-config`.
      #
      # @example `EnforcedStyle: constant` (default)
      #   # bad
      #   let(:foo) do
      #     instance_double('ClassName', method_name: 'returned_value')
      #   end
      #
      #   # good
      #   let(:foo) do
      #     instance_double(ClassName, method_name: 'returned_value')
      #   end
      #
      # @example `EnforcedStyle: string`
      #   # bad
      #   let(:foo) do
      #     instance_double(ClassName, method_name: 'returned_value')
      #   end
      #
      #   # good
      #   let(:foo) do
      #     instance_double('ClassName', method_name: 'returned_value')
      #   end
      #
      # @example Reference is not in the supported style list. No enforcement
      #
      #   # good
      #   let(:foo) do
      #     instance_double(@klass, method_name: 'returned_value')
      #   end
      class VerifiedDoubleReference < Base
        extend AutoCorrector
        include ConfigurableEnforcedStyle

        MSG = 'Use a %<style>s class reference for verified doubles.'

        RESTRICT_ON_SEND = Set[
          :class_double,
          :class_spy,
          :instance_double,
          :instance_spy,
          :mock_model,
          :object_double,
          :object_spy,
          :stub_model
        ].freeze

        REFERENCE_TYPE_STYLES = {
          str: :string,
          const: :constant
        }.freeze

        # @!method verified_double(node)
        def_node_matcher :verified_double, <<~PATTERN
          (send
            nil?
            RESTRICT_ON_SEND
            $_class_reference
            ...)
        PATTERN

        def on_send(node)
          verified_double(node) do |class_reference|
            break correct_style_detected unless opposing_style?(class_reference)

            message = format(MSG, style: style)
            expression = class_reference.loc.expression

            add_offense(expression, message: message) do |corrector|
              violation = class_reference.children.last.to_s
              corrector.replace(expression, correct_style(violation))

              opposite_style_detected
            end
          end
        end

        private

        def opposing_style?(class_reference)
          class_reference_style = REFERENCE_TYPE_STYLES[class_reference.type]

          # Only enforce supported styles
          return false unless class_reference_style

          class_reference_style != style
        end

        def correct_style(violation)
          if style == :string
            "'#{violation}'"
          else
            violation
          end
        end
      end
    end
  end
end
