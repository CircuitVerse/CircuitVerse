# frozen_string_literal: true

class ToggleFeaturedProject < Avo::Actions::ApplicationAction
  self.name = "Toggle Featured"
  self.standalone = true
  self.visible = -> { 
    view == :index && resource&.class&.name == "Project" 
  }

  def handle_action(query:, fields:, current_user:, resource:, **args)
    project = resource

    if project.featured_circuit.present?
      project.featured_circuit.destroy
      project.reload
      success "Project removed from featured"
    else
      FeaturedCircuit.create(project: project, featured_at: Time.current)
      project.reload
      success "Project marked as featured"
    end

    reload
  end

  def success_message
    "Project featured status updated successfully"
  end

  def error_message
    "Failed to update project featured status"
  end
end
