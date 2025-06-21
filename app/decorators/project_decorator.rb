# frozen_string_literal: true

class ProjectDecorator < SimpleDelegator
  # @return [Project]
  def project
    __getobj__
  end

  # @return [String] Project's grade
  def grade_str
    project.grade&.grade.presence || "N.A."
  end

  # @return [String] Project's remarks
  def remarks_str
    project.grade&.remarks.presence || "N.A."
  end
end
