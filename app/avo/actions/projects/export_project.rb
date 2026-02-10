# frozen_string_literal: true
require "csv"

class Avo::Actions::Projects::ExportProject < Avo::BaseAction
  self.name = "Export Project Data"
  self.message = "Export data for selected projects?"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    projects_data = collect_projects_data(query)
    csv_data = generate_csv(projects_data)
    download csv_data, "projects_export_#{Time.zone.now.to_i}.csv"
  end

  private

    def collect_projects_data(query)
      query.includes(:author, :stars).map do |project|
        {
          id: project.id,
          name: project.name,
          author: project.author&.name,
          author_email: project.author&.email,
          access_type: project.project_access_type,
          views: project.view,
          stars: project.stars_count,
          created_at: project.created_at,
          updated_at: project.updated_at
        }
      end
    end

    def generate_csv(data)
      return "" if data.empty?

      CSV.generate(headers: true) do |csv|
        csv << data.first.keys
        data.each { |row| csv << row.values }
      end
    end
end
