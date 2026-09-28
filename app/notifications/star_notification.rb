# frozen_string_literal: true

class StarNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    data = notification_params
    user = data[:user] || (User.find_by(id: data[:user_id]) if data[:user_id])
    project = data[:project] || (Project.find_by(id: data[:project_id]) if data[:project_id])
    t("users.notifications.star_notification", user: user&.name, project: project&.name)
  end

  def icon
    "far fa-star fa-thin"
  end

  private

    def notification_params
      case params
      when Hash
        params.with_indifferent_access
      when Array
        (params.first.is_a?(Hash) ? params.first.with_indifferent_access : {})
      else
        {}
      end
    end
end
