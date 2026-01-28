# frozen_string_literal: true

class Avo::Actions::ResetGroupToken < Avo::BaseAction
  self.name = "Reset Group Token"
  self.message = "Are you sure you want to reset the invitation token for this group?"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each(&:reset_group_token)

    succeed "Group token(s) reset successfully. New tokens will expire in 12 days."
  end
end
