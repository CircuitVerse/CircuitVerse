# frozen_string_literal: true

class Avo::Actions::Projects::ToggleFeaturedProject < Avo::BaseAction
  self.name = "Toggle Featured Status"
  self.message = "Toggle featured status for selected projects?"
  self.confirm_button_label = "Toggle Featured"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each do |project|
      if project.featured?
        project.featured_circuit.destroy!
      elsif project.public?
        FeaturedCircuit.create!(project: project)
      end
    end

    succeed "Featured status toggled for #{query.count} project(s)"
  end
end
