# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = record.params.with_indifferent_access[:user]
    project = record.params.with_indifferent_access[:project]
    t(
      "users.notifications.fork_notification",
      user: user&.name,
      project: project&.name
    )
  end

  def icon
    "fas fa-code-branch"
  end
end
