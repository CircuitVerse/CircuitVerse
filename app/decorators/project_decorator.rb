# frozen_string_literal: true

class ProjectDecorator < SimpleDelegator
  def project
    __getobj__
  end

  def grade_str
    project.grade&.grade.presence || I18n.t("not_available")
  end

  def remarks_str
    project.grade&.remarks.presence || I18n.t("not_available")
  end
end
