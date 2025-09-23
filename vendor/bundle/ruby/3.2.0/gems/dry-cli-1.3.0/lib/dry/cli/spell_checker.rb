# frozen_string_literal: true

require "dry/cli/program_name"
require "did_you_mean"

module Dry
  class CLI
    # Command(s) usage
    #
    # @since 1.1.1
    # @api private
    module SpellChecker
      # @since 1.1.1
      # @api private
      def self.call(result, arguments)
        commands = result.children.keys
        cmd = cmd_to_spell(arguments, result.names)

        suggestions = DidYouMean::SpellChecker.new(dictionary: commands).correct(cmd.first)
        if suggestions.any?
          "I don't know how to '#{cmd.join(" ")}'. Did you mean: '#{suggestions.first}' ?"
        end
      end

      # @since 1.1.1
      # @api private
      def self.cmd_to_spell(arguments, result_names)
        arguments - result_names
      end

      # @since 1.1.1
      # @api private
      def self.ignore?(cmd)
        cmd.empty? || cmd.first.start_with?("-")
      end
    end
  end
end
