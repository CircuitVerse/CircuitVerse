# frozen_string_literal: true

class Avo::Actions::ExportProject < Avo::BaseAction
  self.name = "Export Project Data"
  self.message = "Export data for selected projects?"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    projects_data = query.map do |project|
      {
        id: project.id,
        name: project.name,
        author: project.author.name,
        author_email: project.author.email,
        access_type: project.project_access_type,
        views: project.view,
        stars: project.stars.count,
        created_at: project.created_at,
        updated_at: project.updated_at
      }
    end

    csv_data = CSV.generate(headers: true) do |csv|
      csv << projects_data.first.keys
      projects_data.each do |project_data|
        csv << project_data.values
      end
    end

    download csv_data, "projects_export_#{Time.zone.now.to_i}.csv"
  end
end
