# frozen_string_literal: true

class ProjectDecorator < SimpleDelegator
  def project
    __getobj__
  end

  def grade_str
    project.grade&.grade.present? ? project.grade&.grade : "N.A."
  end

  def remarks_str
    project.grade&.remarks.present? ? project.grade&.remarks : "N.A."
  end
end
