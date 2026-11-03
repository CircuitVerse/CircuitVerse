# frozen_string_literal: true

class GradeScaleMapper
  LETTER_THRESHOLDS = [[90, "A"], [80, "B"], [70, "C"], [60, "D"], [50, "E"]].freeze

  def self.mappable?(assignment)
    assignment.grading_scale != "no_scale"
  end

  def self.call(assignment, fraction)
    return unless mappable?(assignment)

    percent = (fraction * 100).round.clamp(0, 100)
    case scale_for(assignment)
    when "letter" then LETTER_THRESHOLDS.find { |min, _| percent >= min }&.last || "F"
    else percent.to_s
    end
  end

  def self.scale_for(assignment)
    assignment.lti_integrated? ? "percent" : assignment.grading_scale
  end
end
