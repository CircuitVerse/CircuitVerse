# frozen_string_literal: true

class Avo::Actions::Projects::ToggleFeaturedProject < Avo::BaseAction
  self.name = "Toggle Featured Status"
  self.message = "Toggle featured status for selected projects?"
  self.confirm_button_label = "Toggle Featured"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    toggled = 0

    ActiveRecord::Base.transaction do
      query.each do |project|
        if project.featured?
          project.featured_circuit.destroy!
          toggled += 1
        elsif project.public?
          FeaturedCircuit.create!(project: project)
          toggled += 1
        end
      end
    end

    succeed "Featured status toggled for #{toggled} project(s)"
  end
end
