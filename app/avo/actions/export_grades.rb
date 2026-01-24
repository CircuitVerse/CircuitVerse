# frozen_string_literal: true

class Avo::Actions::ExportGrades < Avo::BaseAction
  self.name = "Export Grades"
  self.message = "Export grades for selected assignments?"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    grades_data = []

    query.each do |assignment|
      assignment.grades.includes(project: :author).each do |grade|
        grades_data << {
          assignment_name: assignment.name,
          assignment_id: assignment.id,
          student_name: grade.project.author.name,
          student_email: grade.project.author.email,
          project_name: grade.project.name,
          grade: grade.grade,
          remarks: grade.remarks,
          graded_at: grade.updated_at
        }
      end
    end

    csv_data = CSV.generate(headers: true) do |csv|
      csv << grades_data.first.keys if grades_data.any?
      grades_data.each do |grade_data|
        csv << grade_data.values
      end
    end

    download csv_data, "grades_export_#{Time.zone.now.to_i}.csv"
  end
end
