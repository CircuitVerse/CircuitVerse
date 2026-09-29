# frozen_string_literal: true

module AssignmentsHelper
  def deadline_year(assignment)
    assignment.deadline.strftime("%Y")
  end

  def deadline_month(assignment)
    assignment.deadline.strftime("%m")
  end

  def deadline_day(assignment)
    assignment.deadline.strftime("%-d")
  end

  def deadline_hour(assignment)
    assignment.deadline.strftime("%H")
  end

  def deadline_minute(assignment)
    assignment.deadline.strftime("%M")
  end

  def deadline_second(assignment)
    assignment.deadline.strftime("%S")
  end

  # Empty once marked for destruction, even though it's still attached until save.
  def test_case_groups(assignment)
    testbench = assignment.testbench
    return [] if testbench.nil? || testbench.marked_for_destruction?

    testbench.data&.dig("groups") || []
  end

  # Read-only if any group has more than one value per pin, rather than risk
  # silently truncating it on an unrelated save.
  def test_case_editable?(assignment)
    test_case_groups(assignment).all? do |group|
      (group["n"] || 1) == 1 &&
        (group["inputs"] || []).all? { |pin| Array(pin["values"]).size <= 1 } &&
        (group["outputs"] || []).all? { |pin| Array(pin["values"]).size <= 1 }
    end
  end

  def test_case_suite_type(assignment)
    test_case_groups(assignment).any? ? (assignment.testbench.data["type"] || "comb") : "comb"
  end

  def test_case_pins_to_text(pins)
    (pins || []).map do |pin|
      bits = pin["bitWidth"] && pin["bitWidth"] != 1 ? ":#{pin['bitWidth']}" : ""
      "#{pin['label']}#{bits}=#{Array(pin['values']).first}"
    end.join(",")
  end
end
