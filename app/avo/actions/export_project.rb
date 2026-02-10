# frozen_string_literal: true

class ExportProject < Avo::Actions::ApplicationAction
  self.name = "Export Project"
  self.standalone = true
  self.visible = -> { 
    view == :index && resource&.class&.name == "Project" 
  }

  def handle_action(query:, fields:, current_user:, resource:, **args)
    project = resource
    
    # Create export data
    export_data = {
      id: project.id,
      name: project.name,
      slug: project.slug,
      description: project.description,
      author: project.author&.name,
      created_at: project.created_at,
      updated_at: project.updated_at,
      stars_count: project.stars.count,
      collaborators_count: project.collaborators.count,
      tags: project.tags.pluck(:name),
      featured: project.featured_circuit.present?
    }

    # Generate CSV
    require 'csv'
    csv_data = CSV.generate do |csv|
      csv << export_data.keys
      csv << export_data.values
    end

    # Return file download
    {
      type: :file,
      filename: "project_#{project.id}_export.csv",
      content: csv_data,
      content_type: 'text/csv'
    }
  end

  def success_message
    "Project exported successfully"
  end

  def error_message
    "Failed to export project"
  end
end
