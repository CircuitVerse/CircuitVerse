# frozen_string_literal: true

class ContestWinnerNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    project = params[:project] if params[:project].is_a?(Project)
    project ||= Project.find_by(id: params[:project_id] || params["project_id"])
    if params[:project].is_a?(Integer) || params[:project].is_a?(String)
      project ||= Project.find_by(id: params[:project])
    end

    return "Congratulations, your circuit got featured in CircuitVerse." unless project

    "Congratulations, your circuit #{project.name} got featured in CircuitVerse."
  end

  def icon
    "fa fa-trophy"
  end
end
