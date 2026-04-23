# frozen_string_literal: true

require 'set'

module FsmSynthesizer
  # EquationOptimizer: Simplifies and optimizes FSM equations using Boolean algebra
  #
  # Purpose:
  #   Reduces gate count and power consumption through equation simplification
  #   Applies Boolean algebra rules (absorption, consensus, factoring)
  #   Measures optimization quality (gate reduction percentage)
  #
  # Optimization Techniques:
  #   1. Term elimination - Remove redundant terms
  #   2. Factoring - Extract common factors
  #   3. Consensus - Apply consensus theorem
  #   4. Absorption - Apply absorption law
  #
  # Example:
  #   optimizer = FsmSynthesizer::EquationOptimizer.new
  #   optimized = optimizer.optimize_equations(fsm, excitation_equations)
  #   report = optimizer.get_optimization_report(original, optimized)

  class EquationOptimizer
    attr_accessor :optimization_rules
    attr_accessor :report

    def initialize
      @optimization_rules = [
        :eliminate_redundant_terms,
        :factor_common_expressions,
        :apply_absorption,
        :apply_consensus,
        :remove_tautologies
      ]
      @report = {}
    end

    # Optimize a set of equations
    #
    # Parameters:
    #   fsm - FSM object
    #   equations - Hash of equation_id => expression
    #   options - Hash:
    #     :aggressive - Boolean (default: false) - Apply more optimizations
    #     :rules - Array of rule names to apply
    #
    # Returns:
    #   Hash of optimized equations
    def optimize_equations(fsm, equations, options = {})
      optimized = {}
      @report = {
        original_equations: equations.dup,
        optimizations_applied: [],
        statistics: {
          original_gate_count: 0,
          optimized_gate_count: 0,
          reduction_percent: 0.0
        }
      }

      # Count original gates
      original_gates = count_total_gates(equations)
      @report[:statistics][:original_gate_count] = original_gates

      rules = options[:rules] || @optimization_rules
      aggressive = options[:aggressive] || false

      # Optimize each equation
      equations.each do |eq_id, expression|
        optimized_expr = expression

        rules.each do |rule|
          prev_expr = optimized_expr
          optimized_expr = send(rule, optimized_expr, aggressive)
          
          if optimized_expr != prev_expr
            @report[:optimizations_applied] << {
              equation: eq_id,
              rule: rule.to_s,
              before: prev_expr,
              after: optimized_expr
            }
          end
        end

        optimized[eq_id] = optimized_expr
      end

      # Count optimized gates
      optimized_gates = count_total_gates(optimized)
      @report[:statistics][:optimized_gate_count] = optimized_gates
      
      if original_gates > 0
        reduction = ((original_gates - optimized_gates).to_f / original_gates * 100).round(1)
        @report[:statistics][:reduction_percent] = reduction
      end

      optimized
    end

    # Get optimization report
    #
    # Returns:
    #   Hash with optimization details
    def get_optimization_report
      @report
    end

    # Estimate gate count for logical expression
    #
    # Parameters:
    #   expression - Boolean expression string
    #
    # Returns:
    #   Integer gate count
    def count_gates(expression)
      return 0 if expression.blank?

      count = 0

      # Count AND gates
      count += expression.scan(/&/).length

      # Count OR gates
      count += expression.scan(/\|/).length

      # Count NOT gates
      count += expression.scan(/~/).length

      count
    end

    # Private optimization rules

    private

    def eliminate_redundant_terms(expression, aggressive = false)
      return expression if expression.blank?

      # Remove duplicate terms
      # Example: (A&B) | (A&B) => (A&B)
      terms = extract_terms(expression)
      unique_terms = terms.uniq
      
      if unique_terms.length < terms.length
        return unique_terms.join(' | ')
      end

      expression
    end

    def factor_common_expressions(expression, aggressive = false)
      return expression if expression.blank?

      # Factor out common subexpressions
      # Example: (A&B) | (A&C) => A&(B|C)
      
      # Simple heuristic: look for AND terms with common variables
      terms = expression.split(/\s*\|\s*/).map(&:strip)
      
      if terms.length >= 2 && aggressive
        common = find_common_factor(terms)
        if common
          residuals = terms.map { |t| remove_factor(t, common) }
          # Guard: only factor if residuals are non-empty
          return expression if residuals.any?(&:blank?)
          return "#{common} & (#{residuals.join(' | ')})"
        end
      end

      expression
    end

    def apply_absorption(expression, aggressive = false)
      return expression if expression.blank?

      # Absorption law: A | (A & B) = A
      # A & (A | B) = A
      
      variants = [
        # A | (A & ...) => A
        [/([A-Za-z0-9_~]+)\s*\|\s*\(\1\s*&[^)]*\)/, '\1'],
        # (A & ...) | A => A
        [/\([A-Za-z0-9_~]+\s*&[^)]*\)\s*\|\s*([A-Za-z0-9_~]+)/, '\1'],
      ]

      result = expression
      variants.each do |pattern, replacement|
        result = result.gsub(pattern, replacement)
      end

      result
    end

    def apply_consensus(expression, aggressive = false)
      return expression if expression.blank?

      # Consensus theorem: (A&B) | (~A&C) | (B&C) => (A&B) | (~A&C)
      # For now, simplified version
      
      if aggressive
        # Look for patterns where consensus can apply
        # This is simplified - real consensus detection is complex
        expression = expression.gsub(/\(\s*~?[A-Za-z0-9_]+\s*&\s*~?[A-Za-z0-9_]+\s*\)\s*\|\s*\1/, '\1')
      end

      expression
    end

    def remove_tautologies(expression, aggressive = false)
      return expression if expression.blank?

      # Remove tautologies: A | ~A => 1 (remove from expression)
      # A & ~A => 0 (make expression 0)

      variables = extract_variables(expression)
      
      variables.each do |var|
        # Check for var | ~var (tautology)
        if expression.include?("#{var}") && expression.include?("~#{var}")
          # This would make entire OR clause true
          expression = expression.gsub(/[^|&()\s]*#{Regexp.escape(var)}[^|&()\s]*\s*\|\s*[^|&()\s]*~#{Regexp.escape(var)}[^|&()\s]*/, '1')
        end
      end

      # Remove redundant 0 and 1
      expression = expression.gsub(/\(\s*0\s*\)/, '0')
      expression = expression.gsub(/\(\s*1\s*\)/, '1')
      
      # Guard aggressive simplification: check for full expression reduction first
      if aggressive
        # 1 | X = 1 (entire expression becomes true)
        return '1' if expression.match?(/(^|\W)1\s*\|/) || expression.match?(/\|\s*1(\W|$)/)
        # 0 & X = 0 (entire expression becomes false)
        return '0' if expression.match?(/(^|\W)0\s*&/) || expression.match?(/&\s*0(\W|$)/)
      end

      expression
    end

    def count_total_gates(equations)
      total = 0
      equations.each_value do |expr|
        total += count_gates(expr)
      end
      total
    end

    def extract_terms(expression)
      # Split by OR operator, handling parentheses
      expression.split(/\s*\|\s*/).map(&:strip)
    end

    def extract_variables(expression)
      # Find all variable names
      expression.scan(/([A-Za-z0-9_]+)/).flatten.uniq
    end

    def find_common_factor(terms)
      # Find variables common to all terms
      return nil if terms.empty?

      common_vars = Set.new(extract_variables(terms[0]))
      
      terms[1..].each do |term|
        term_vars = Set.new(extract_variables(term))
        common_vars &= term_vars
      end

      return nil if common_vars.empty?
      common_vars.first
    end

    def remove_factor(term, factor)
      # Remove factor from term
      term.gsub(/#{Regexp.escape(factor)}\s*&/, '').gsub(/&\s*#{Regexp.escape(factor)}/, '').strip
    end
  end
end
