module Regexp::Expression
  # A sequence of expressions. Differs from a Subexpressions by how it handles
  # quantifiers, as it applies them to its last element instead of itself as
  # a whole subexpression.
  #
  # Used as the base class for the Alternation alternatives, Conditional
  # branches, and CharacterSet::Intersection intersected sequences.
  class Sequence < Regexp::Expression::Subexpression
    class << self
      def add_to(exp, params = {}, active_opts = {})
        sequence = construct(
          level:             exp.level,
          set_level:         exp.set_level,
          conditional_level: params[:conditional_level] || exp.conditional_level,
        )
        sequence.options = active_opts
        exp.expressions << sequence
        sequence
      end
    end

    def starts_at
      expressions.first.starts_at
    end
    alias :ts :starts_at

    def quantify(*args)
      target = expressions.reverse.find { |exp| !exp.is_a?(FreeSpace) }
      target or raise Regexp::Parser::Error,
        "No valid target found for '#{text}' quantifier"

      target.quantify(*args)
    end
  end
end
