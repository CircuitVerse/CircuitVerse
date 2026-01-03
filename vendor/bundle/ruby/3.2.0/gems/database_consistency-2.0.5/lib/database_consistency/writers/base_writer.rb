# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    # The base class for writers
    class BaseWriter
      attr_reader :results, :config

      def initialize(results, config: Configuration.new)
        @results = results
        @config = config
      end

      def self.write(results, config: Configuration.new)
        new(results, config: config).write
      end
    end
  end
end
