# frozen_string_literal: true

class ContestWinnerNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    project = params[:project]
    "Congratulations, your circuit #{project.name} got featured in the CircuitVerse."
  end

  def icon
    "fa fa-trophy"
  end
end
