# frozen_string_literal: true

class Avo::Actions::ToggleAdminStatus < Avo::BaseAction
  self.name = "Toggle Admin Status"
  self.message = "Are you sure you want to toggle admin status for selected users?"
  self.confirm_button_label = "Toggle Admin"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each do |user|
      user.update!(admin: !user.admin?)
    end

    succeed "Admin status toggled for #{query.count} user(s)"
  end
end
