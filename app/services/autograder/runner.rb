# frozen_string_literal: true

module Autograder
  class Runner
    class RunnerError < StandardError; end

    DEFAULT_URL = "http://127.0.0.1:3050"
    TIMEOUTS = { connect: 5, write: 10, read: 60 }.freeze

    Result = Struct.new(:passed, :total, :groups) do
      def score
        total.zero? ? 0.0 : passed.fdiv(total)
      end
    end

    def self.call(project:, testbench:)
      new(project, testbench).call
    end

    def initialize(project, testbench)
      @project = project
      @testbench = testbench
    end

    def call
      summarise(run)
    end

    private

      attr_reader :project, :testbench

      def run
        response = HTTP.timeout(**TIMEOUTS)
                       .post(endpoint, json: { circuit: circuit, testbench: testbench.data })
        raise RunnerError, "Runner returned #{response.status}" unless response.status.success?

        JSON.parse(response.body.to_s)
      rescue HTTP::Error => e
        raise RunnerError, "Runner unreachable: #{e.message}"
      rescue JSON::ParserError
        raise RunnerError, "Runner returned invalid JSON"
      end

      def circuit
        JSON.parse(project.project_datum&.data.to_s)
      rescue JSON::ParserError
        raise RunnerError, "Project has no runnable circuit data"
      end

      def endpoint
        "#{ENV.fetch('SIMULATOR_RUNNER_URL', DEFAULT_URL)}/run"
      end

      def summarise(payload)
        groups = payload["groups"]
        raise RunnerError, "Runner returned no results" unless groups.is_a?(Array) && groups.any?

        cases = groups.flat_map { |group| Array(group["cases"]) }
        Result.new(cases.count { |kase| kase["passed"] }, cases.size, groups)
      end
  end
end
