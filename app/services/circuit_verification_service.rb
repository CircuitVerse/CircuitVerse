# frozen_string_literal: true

class CircuitVerificationService
  Result = Struct.new(:passed, :score, :failed_cases, keyword_init: true)

  def initialize(assignment, project)
    @assignment = assignment
    @project    = project
  end

  def verify!
    test_cases = @assignment.assignment_test_cases
    return Result.new(passed: true, score: 100.0, failed_cases: []) if test_cases.empty?

    failed = []
    test_cases.each do |tc|
      actual = simulate_circuit(tc.input_pins)
      failed << tc unless tc.pass?(actual)
    end

    passed = failed.empty?
    score  = ((test_cases.count - failed.count).to_f / test_cases.count * 100).round(2)

    Result.new(passed: passed, score: score, failed_cases: failed)
  end

  private

  def simulate_circuit(input_pins)
    # In production: parse project.circuit_data and evaluate gates
    # Real implementation during GSoC
    {}
  end
end
