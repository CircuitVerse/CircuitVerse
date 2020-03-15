# frozen_string_literal: true

module ERBLint
  class Corrector
    attr_reader :processed_source, :offenses, :corrected_content

    def initialize(processed_source, offenses)
      @processed_source = processed_source
      @offenses = offenses
      @corrected_content = corrector.rewrite
    end

    def corrections
      @corrections ||= @offenses.map do |offense|
        offense.linter.autocorrect(@processed_source, offense)
      end.compact
    end

    def corrector
      RuboCop::Cop::Corrector.new(@processed_source.source_buffer, corrections)
    end

    def diagnostics
      corrector.diagnostics
    end
  end
end
