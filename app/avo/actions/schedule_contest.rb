# frozen_string_literal: true

class Avo::Actions::ScheduleContest < Avo::BaseAction
  self.name = "Schedule Contest"
  self.message = "This will schedule/reschedule the contest"

  # Only show for live or upcoming contests
  self.visible = lambda {
    # On index page, resource.record is nil, so show the action
    return true if resource.nil? || resource.record.nil?

    # On show/edit pages, only show for live or upcoming
    %w[live upcoming].include?(resource.record.status)
  }

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each do |contest|
      ContestScheduler.call(contest)
    end

    succeed "Contest(s) scheduled successfully!"
  end
end
