# frozen_string_literal: true

class ContestNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    "New Contest in CircuitVerse, Check it out."
  end

  def icon
    "fa fa-trophy"
  end
end
