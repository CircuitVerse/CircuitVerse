# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Autofix
      class Base # :nodoc:
        attr_reader :report

        def initialize(report)
          @report = report
        end
      end
    end
  end
end
