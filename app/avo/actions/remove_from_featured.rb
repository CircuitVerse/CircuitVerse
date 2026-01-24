# frozen_string_literal: true

class Avo::Actions::RemoveFromFeatured < Avo::BaseAction
  self.name = "Remove from Featured"
  self.message = "Remove selected projects from featured?"
  self.confirm_button_label = "Remove"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each do |featured_circuit|
      featured_circuit.destroy!
    end

    succeed "Removed #{query.count} project(s) from featured"
  end
end
