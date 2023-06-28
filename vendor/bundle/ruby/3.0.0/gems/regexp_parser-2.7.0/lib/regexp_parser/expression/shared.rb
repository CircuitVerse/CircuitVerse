module Regexp::Expression
  module Shared
    module ClassMethods; end # filled in ./methods/*.rb

    def self.included(mod)
      mod.class_eval do
        extend Shared::ClassMethods

        attr_accessor :type, :token, :text, :ts, :te,
                      :level, :set_level, :conditional_level,
                      :options

        attr_reader   :nesting_level, :quantifier
      end
    end

    def init_from_token_and_options(token, options = {})
      self.type              = token.type
      self.token             = token.token
      self.text              = token.text
      self.ts                = token.ts
      self.te                = token.te
      self.level             = token.level
      self.set_level         = token.set_level
      self.conditional_level = token.conditional_level
      self.nesting_level     = 0
      self.options           = options || {}
    end
    private :init_from_token_and_options

    def initialize_copy(orig)
      self.text       = orig.text.dup         if orig.text
      self.options    = orig.options.dup      if orig.options
      self.quantifier = orig.quantifier.clone if orig.quantifier
      super
    end

    def starts_at
      ts
    end

    def base_length
      to_s(:base).length
    end

    def full_length
      to_s.length
    end

    def to_s(format = :full)
      "#{parts.join}#{quantifier_affix(format)}"
    end
    alias :to_str :to_s

    def parts
      [text.dup]
    end

    def quantifier_affix(expression_format)
      quantifier.to_s if quantified? && expression_format != :base
    end

    def quantified?
      !quantifier.nil?
    end

    def optional?
      quantified? && quantifier.min == 0
    end

    def offset
      [starts_at, full_length]
    end

    def coded_offset
      '@%d+%d' % offset
    end

    def terminal?
      true # overridden to be false in Expression::Subexpression
    end

    def referential?
      false # overridden to be true e.g. in Expression::Backreference::Base
    end

    def nesting_level=(lvl)
      @nesting_level = lvl
      quantifier && quantifier.nesting_level = lvl
      terminal? || each { |subexp| subexp.nesting_level = lvl + 1 }
    end

    def quantifier=(qtf)
      @quantifier = qtf
      @repetitions = nil # clear memoized value
    end
  end
end
