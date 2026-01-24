# frozen_string_literal: true

class Avo::Actions::RegenerateGroupToken < Avo::BaseAction
  self.name = "Regenerate Group Token"
  self.message = "Regenerate invitation token for selected groups?"
  self.confirm_button_label = "Regenerate"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each do |group|
      group.reset_group_token
    end

    succeed "Token regenerated for #{query.count} group(s)"
  end
end
