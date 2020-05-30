# frozen_string_literal: true

class ProjectDecorator < SimpleDelegator
  def project
    __getobj__
  end

  def grade_str
    project.grade&.grade.presence || "N.A."
  end

  def remarks_str
    project.grade&.remarks.presence || "N.A."
  end
end
