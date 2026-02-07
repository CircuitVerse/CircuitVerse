# frozen_string_literal: true

class Avo::Actions::ExportGrades < Avo::BaseAction
  self.name = "Export Grades"
  self.message = "Export grades for selected assignments?"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    grades_data = collect_grades_data(query)
    csv_data = generate_csv(grades_data)
    download csv_data, "grades_export_#{Time.zone.now.to_i}.csv"
  end

  private

    def collect_grades_data(query)
      [].tap do |data|
        query.each do |assignment|
          assignment.grades.includes(project: :author).find_each do |grade|
            data << build_grade_hash(assignment, grade)
          end
        end
      end
    end

    def build_grade_hash(assignment, grade)
      {
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

    def generate_csv(data)
      CSV.generate(headers: true) do |csv|
        csv << data.first.keys if data.any?
        data.each { |row| csv << row.values }
      end
    end
end
