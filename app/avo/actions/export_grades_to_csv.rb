# frozen_string_literal: true

class Avo::Actions::ExportGradesToCsv < Avo::BaseAction
  self.name = "Export to CSV"
  self.visible = lambda {
    return false if resource.nil?

    true
  }

  def fields
    field :assignment_id, as: :select,
                          options: -> { Assignment.pluck(:name, :id) },
                          required: true,
                          help: "Select assignment to export grades"
  end

  def handle(_query:, fields:, _current_user:, _resource:, **_args)
    assignment_id = fields[:assignment_id]

    return error "Please select an assignment" if assignment_id.blank?

    csv_data = Grade.to_csv(assignment_id)
    assignment = Assignment.find(assignment_id)

    download csv_data, "grades_#{assignment.name.parameterize}_#{Time.zone.today}.csv"

    succeed "Grades exported successfully"
  end
end
