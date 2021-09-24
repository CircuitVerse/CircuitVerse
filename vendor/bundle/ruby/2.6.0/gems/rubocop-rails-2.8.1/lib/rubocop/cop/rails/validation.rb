# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of old-style attribute validation macros.
      #
      # @example
      #   # bad
      #   validates_acceptance_of :foo
      #   validates_confirmation_of :foo
      #   validates_exclusion_of :foo
      #   validates_format_of :foo
      #   validates_inclusion_of :foo
      #   validates_length_of :foo
      #   validates_numericality_of :foo
      #   validates_presence_of :foo
      #   validates_absence_of :foo
      #   validates_size_of :foo
      #   validates_uniqueness_of :foo
      #
      #   # good
      #   validates :foo, acceptance: true
      #   validates :foo, confirmation: true
      #   validates :foo, exclusion: true
      #   validates :foo, format: true
      #   validates :foo, inclusion: true
      #   validates :foo, length: true
      #   validates :foo, numericality: true
      #   validates :foo, presence: true
      #   validates :foo, absence: true
      #   validates :foo, size: true
      #   validates :foo, uniqueness: true
      #
      class Validation < Cop
        MSG = 'Prefer the new style validations `%<prefer>s` over ' \
              '`%<current>s`.'

        TYPES = %w[
          acceptance
          confirmation
          exclusion
          format
          inclusion
          length
          numericality
          presence
          absence
          size
          uniqueness
        ].freeze

        DENYLIST = TYPES.map { |p| "validates_#{p}_of".to_sym }.freeze
        ALLOWLIST = TYPES.map { |p| "validates :column, #{p}: value" }.freeze

        def on_send(node)
          return unless !node.receiver && DENYLIST.include?(node.method_name)

          add_offense(node, location: :selector)
        end

        def autocorrect(node)
          last_argument = node.arguments.last
          return if !last_argument.literal? && !last_argument.splat_type? &&
                    !frozen_array_argument?(last_argument)

          lambda do |corrector|
            corrector.replace(node.loc.selector, 'validates')
            correct_validate_type(corrector, node)
          end
        end

        private

        def message(node)
          format(MSG, prefer: preferred_method(node.method_name),
                      current: node.method_name)
        end

        def preferred_method(method)
          ALLOWLIST[DENYLIST.index(method.to_sym)]
        end

        def correct_validate_type(corrector, node)
          last_argument = node.last_argument

          if last_argument.hash_type?
            correct_validate_type_for_hash(corrector, node, last_argument)
          elsif last_argument.array_type?
            loc = last_argument.loc

            correct_validate_type_for_array(corrector, node, last_argument, loc)
          elsif frozen_array_argument?(last_argument)
            arguments = node.last_argument.receiver
            loc = arguments.parent.loc

            correct_validate_type_for_array(corrector, node, arguments, loc)
          else
            range = last_argument.source_range

            corrector.insert_after(range, ", #{validate_type(node)}: true")
          end
        end

        def correct_validate_type_for_hash(corrector, node, arguments)
          corrector.replace(
            arguments.loc.expression,
            "#{validate_type(node)}: #{braced_options(arguments)}"
          )
        end

        def correct_validate_type_for_array(corrector, node, arguments, loc)
          attributes = []

          arguments.each_child_node do |child_node|
            attributes << if arguments.percent_literal?
                            ":#{child_node.source}"
                          else
                            child_node.source
                          end
          end

          corrector.replace(
            loc.expression,
            "#{attributes.join(', ')}, #{validate_type(node)}: true"
          )
        end

        def validate_type(node)
          node.method_name.to_s.split('_')[1]
        end

        def frozen_array_argument?(argument)
          argument.send_type? && argument.method?(:freeze)
        end

        def braced_options(options)
          if options.braces?
            options.source
          else
            "{ #{options.source} }"
          end
        end
      end
    end
  end
end
