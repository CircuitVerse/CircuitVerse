# FSM Validation Service
module FsmSynthesizer
  class Validator
    def self.validate(fsm)
      fsm.validate
    end

    # Check for deterministic transitions (no conflicts)
    def self.check_determinism(fsm)
      seen = {}
      conflicts = []

      fsm.transitions.each do |transition|
        key = [transition[:from], transition[:input]]
        if seen[key]
          conflicts << "Duplicate transition: #{transition[:from]} --[#{transition[:input]}]--> (conflict)"
        end
        seen[key] = transition
      end

      raise FsmSynthesizer::ValidationError, conflicts.join("; ") unless conflicts.empty?

      true
    end

    # Check for transition completeness
    def self.check_completeness(fsm)
      missing = []

      fsm.states.each do |state|
        fsm.inputs.each do |input|
          has_transition = fsm.transitions.any? { |t| t[:from] == state[:id] && t[:input] == input }
          missing << "Missing transition: #{state[:id]} --[#{input}]--> ?" unless has_transition
        end
      end

      raise FsmSynthesizer::ValidationError, missing.join("; ") unless missing.empty?

      true
    end
  end
end
