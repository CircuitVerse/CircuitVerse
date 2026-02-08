# frozen_string_literal: true

class Avo::Filters::MaintenanceTasksStatus < Avo::Filters::SelectFilter
  self.name = "Status"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(status: value)
  end

  def options
    {
      enqueued: "Enqueued",
      running: "Running",
      succeeded: "Succeeded",
      paused: "Paused",
      interrupted: "Interrupted",
      errored: "Errored",
      cancelled: "Cancelled"
    }
  end
end
