# frozen_string_literal: true

class Avo::Actions::ExportMaintenanceTasksRuns < Avo::BaseAction
  self.name = "Export Task Runs"
  self.message = "Export selected task runs to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(query:, _fields:, _current_user:, _resource:, **)
    filename = "maintenance_tasks_runs_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "Task Name", "Status", "Started At", "Ended At", "Time Running", "Tick Count", "Error Class"]

      query.each do |record|
        csv << csv_row(record)
      end
    end

    download csv_data, filename

    succeed "Exported #{query.count} task runs"
  end

  private

    def csv_row(record)
      [
        record.id,
        record.task_name,
        record.status,
        record.started_at&.strftime("%Y-%m-%d %H:%M:%S"),
        record.ended_at&.strftime("%Y-%m-%d %H:%M:%S"),
        record.time_running,
        record.tick_count,
        record.error_class
      ]
    end
end
