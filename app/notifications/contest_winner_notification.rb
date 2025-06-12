# frozen_string_literal: true

class ContestWinnerNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    project = params[:project]
    return "Congratulations, your circuit got featured in CircuitVerse." unless project
    "Congratulations, your circuit #{project.name} got featured in CircuitVerse."
  end

  def icon
    "fa fa-trophy"
  end
end
